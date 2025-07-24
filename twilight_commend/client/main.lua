local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-commend:client:showLeaderboard', function(leaderboard)
    local options = {}
    
    if #leaderboard > 0 then
        table.insert(options, {
            title = '🏆 Commendation Leaderboard',
            description = 'Top commended players on the server',
            icon = 'trophy',
            disabled = true
        })
        
        for i, player in ipairs(leaderboard) do
            local medal = ''
            if i == 1 then
                medal = '🥇 '
            elseif i == 2 then
                medal = '🥈 '
            elseif i == 3 then
                medal = '🥉 '
            else
                medal = '#' .. i .. ' '
            end
            
            table.insert(options, {
                title = medal .. player.playername,
                description = string.format('Commends: %d | Last reason: %s', 
                    player.commend_count, 
                    player.last_commend_reason and string.sub(player.last_commend_reason, 1, 50) .. (string.len(player.last_commend_reason) > 50 and '...' or '') or 'No reason recorded'
                ),
                icon = i <= 3 and 'crown' or 'user',
                disabled = true
            })
        end
    else
        table.insert(options, {
            title = '📋 No Commends Yet',
            description = 'Be the first to commend someone for good behavior!',
            icon = 'info',
            disabled = true
        })
    end
    
    table.insert(options, {
        title = 'Close',
        description = 'Close the leaderboard',
        icon = 'x',
        onSelect = function()
            lib.hideContext()
        end
    })
    
    lib.registerContext({
        id = 'commend_leaderboard',
        title = Config.Leaderboard.title or 'Commendation Leaderboard',
        options = options
    })
    
    lib.showContext('commend_leaderboard')
end)

RegisterNetEvent('qb-commend:client:openCommendMenu', function(players)
    local options = {}
    
    table.insert(options, {
        title = '👥 Select Player to Commend',
        description = 'Choose a player to give a commendation',
        icon = 'users',
        disabled = true
    })
    
    table.insert(options, {
        title = '─────────────────────────',
        disabled = true
    })
    
    if #players > 0 then
        for _, player in ipairs(players) do
            table.insert(options, {
                title = player.name,
                description = string.format('Server ID: %s | Click to commend', player.id),
                icon = 'user',
                onSelect = function()
                    OpenCommendDialog(player.id, player.name)
                end
            })
        end
    else
        table.insert(options, {
            title = 'No Players Online',
            description = 'No other players are currently online to commend',
            icon = 'user-x',
            disabled = true
        })
    end
    
    table.insert(options, {
        title = '─────────────────────────',
        disabled = true
    })
    
    table.insert(options, {
        title = 'Close',
        description = 'Close the menu',
        icon = 'x',
        onSelect = function()
            lib.hideContext()
        end
    })
    
    lib.registerContext({
        id = 'commend_menu',
        title = 'Commend Player',
        options = options
    })
    
    lib.showContext('commend_menu')
end)

function OpenCommendDialog(playerId, playerName)
    local input = lib.inputDialog('Commend Player', {
        {
            type = 'input',
            label = 'Player Name',
            value = playerName,
            disabled = true,
            icon = 'user'
        },
        {
            type = 'textarea',
            label = 'Reason for Commendation',
            description = 'Explain why this player deserves recognition',
            placeholder = 'Enter a detailed reason for commending this player...',
            required = true,
            min = 5,
            max = 200,
            icon = 'message-square'
        }
    })
    
    if input then
        local reason = input[2]
        if reason and reason ~= '' then
            TriggerServerEvent('qb-commend:server:commendPlayer', playerId, reason)
        else
            QBCore.Functions.Notify('Please enter a reason for the commendation', 'error')
        end
    end
end

RegisterCommand('commendmenu', function()
    TriggerServerEvent('qb-commend:server:openCommendMenu')
end)

local function AddToAdminMenu()
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
end)

TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.commend, 'Commend a player for good behavior', {
    { name = 'id', help = 'Player ID' },
    { name = 'reason', help = 'Reason for commendation' }
})

TriggerEvent('chat:addSuggestion', '/' .. Config.Commands.leaderboard, 'Show commendation leaderboard')

TriggerEvent('chat:addSuggestion', '/commendmenu', 'Open commend menu (Admin only)')

exports('OpenCommendMenu', function()
    TriggerServerEvent('qb-commend:server:openCommendMenu')
end)

exports('ShowLeaderboard', function()
    ExecuteCommand(Config.Commands.leaderboard)
end)