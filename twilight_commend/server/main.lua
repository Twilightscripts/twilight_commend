local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `]] .. Config.DatabaseTable .. [[` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `playername` varchar(255) NOT NULL,
            `commend_count` int(11) DEFAULT 0,
            `last_commend_reason` text DEFAULT NULL,
            `last_commend_date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

local function HasAdminPermission(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    for _, group in ipairs(Config.AdminGroups) do
        if QBCore.Functions.HasPermission(source, group) then
            return true
        end
    end
    return false
end

local function GetPlayerById(playerId)
    local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
    return Player
end

local function AddCommend(citizenid, playername, reason)
    MySQL.query('SELECT commend_count FROM ' .. Config.DatabaseTable .. ' WHERE citizenid = ?', {citizenid}, function(result)
        if result[1] then
            MySQL.update('UPDATE ' .. Config.DatabaseTable .. ' SET commend_count = commend_count + 1, last_commend_reason = ?, last_commend_date = NOW() WHERE citizenid = ?', {
                reason, citizenid
            })
        else
            MySQL.insert('INSERT INTO ' .. Config.DatabaseTable .. ' (citizenid, playername, commend_count, last_commend_reason) VALUES (?, ?, 1, ?)', {
                citizenid, playername, reason
            })
        end
    end)
end

local function GetLeaderboard(cb)
    MySQL.query('SELECT playername, commend_count, last_commend_reason, DATE_FORMAT(last_commend_date, "%Y-%m-%d %H:%i") as formatted_date FROM ' .. Config.DatabaseTable .. ' ORDER BY commend_count DESC LIMIT ?', {
        Config.Leaderboard.maxEntries
    }, function(result)
        local processedResult = {}
        for i, row in ipairs(result) do
            table.insert(processedResult, {
                playername = row.playername or 'Unknown Player',
                commend_count = row.commend_count or 0,
                last_commend_reason = row.last_commend_reason or 'No reason recorded',
                last_commend_date = row.formatted_date or 'Unknown date',
                rank = i
            })
        end
        cb(processedResult)
    end)
end

QBCore.Commands.Add(Config.Commands.commend, 'Commend a player (Admin Only)', {
    {name = 'id', help = 'Player ID'},
    {name = 'reason', help = 'Reason for commendation'}
}, true, function(source, args)
    local src = source
    
    if not HasAdminPermission(src) then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.noPermission, 'error')
        return
    end
    
    if not args[1] or not args[2] then
        TriggerClientEvent('QBCore:Notify', src, string.format(Config.Notifications.commandUsage, Config.Commands.commend), 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    local reason = table.concat(args, ' ', 2)
    
    if targetId == src then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.selfCommend, 'error')
        return
    end
    
    local targetPlayer = GetPlayerById(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.playerNotFound, 'error')
        return
    end
    
    local adminPlayer = QBCore.Functions.GetPlayer(src)
    
    AddCommend(targetPlayer.PlayerData.citizenid, targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname, reason)
    
    TriggerClientEvent('QBCore:Notify', src, Config.Notifications.commendSuccess, 'success')
    
    TriggerClientEvent('QBCore:Notify', targetId, string.format(Config.Notifications.commendReceived, reason), 'success')
    
    if Config.ChatAnnouncement.enabled then
        local playerName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
        local message = string.format(Config.ChatAnnouncement.message, playerName, reason)
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 255, 255},
            multiline = true,
            args = {'[COMMEND]', message}
        })
    end
    
    print(string.format('[COMMEND] %s (ID: %s) commended %s (ID: %s) for: %s', 
        adminPlayer.PlayerData.charinfo.firstname .. ' ' .. adminPlayer.PlayerData.charinfo.lastname,
        src,
        targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
        targetId,
        reason
    ))
end)

QBCore.Commands.Add(Config.Commands.leaderboard, 'Show commendation leaderboard', {}, false, function(source, args)
    local src = source
    
    GetLeaderboard(function(leaderboard)
        TriggerClientEvent('qb-commend:client:showLeaderboard', src, leaderboard)
    end)
end)

RegisterNetEvent('qb-commend:server:openCommendMenu', function()
    local src = source
    
    if not HasAdminPermission(src) then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.noPermission, 'error')
        return
    end
    
    local players = {}
    for _, player in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(player)
        if Player and player ~= src then
            table.insert(players, {
                id = player,
                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                citizenid = Player.PlayerData.citizenid
            })
        end
    end
    
    table.sort(players, function(a, b)
        return a.name < b.name
    end)
    
    TriggerClientEvent('qb-commend:client:openCommendMenu', src, players)
end)

RegisterNetEvent('qb-commend:server:commendPlayer', function(targetId, reason)
    local src = source
    
    if not HasAdminPermission(src) then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.noPermission, 'error')
        return
    end
    
    if not targetId or not reason or reason == '' then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid data provided', 'error')
        return
    end
    
    if tonumber(targetId) == src then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.selfCommend, 'error')
        return
    end
    
    local targetPlayer = GetPlayerById(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.playerNotFound, 'error')
        return
    end
    
    local adminPlayer = QBCore.Functions.GetPlayer(src)
    
    AddCommend(targetPlayer.PlayerData.citizenid, targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname, reason)
    
    TriggerClientEvent('QBCore:Notify', src, Config.Notifications.commendSuccess, 'success')
    
    TriggerClientEvent('QBCore:Notify', targetId, string.format(Config.Notifications.commendReceived, reason), 'success')
    
    if Config.ChatAnnouncement.enabled then
        local playerName = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname
        local message = string.format(Config.ChatAnnouncement.message, playerName, reason)
        TriggerClientEvent('chat:addMessage', -1, {
            color = {255, 255, 255},
            multiline = true,
            args = {'[COMMEND]', message}
        })
    end
    
    print(string.format('[COMMEND] %s (ID: %s) commended %s (ID: %s) for: %s', 
        adminPlayer.PlayerData.charinfo.firstname .. ' ' .. adminPlayer.PlayerData.charinfo.lastname,
        src,
        targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
        targetId,
        reason
    ))
end)

exports('GetPlayerCommends', function(citizenid)
    local promise = promise.new()
    MySQL.query('SELECT commend_count FROM ' .. Config.DatabaseTable .. ' WHERE citizenid = ?', {citizenid}, function(result)
        promise:resolve(result[1] and result[1].commend_count or 0)
    end)
    return Citizen.Await(promise)
end)

exports('GetLeaderboard', function()
    local promise = promise.new()
    GetLeaderboard(function(result)
        promise:resolve(result)
    end)
    return Citizen.Await(promise)
end)