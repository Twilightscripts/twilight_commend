Config = {}

Config.AdminGroups = {
    'admin',
    'god',
    'superadmin'
}

Config.Commands = {
    commend = 'commend',
    leaderboard = 'commendboard'
}

Config.Notifications = {
    commendSuccess = 'Player has been commended successfully!',
    commendReceived = 'You have been commended by an admin for: %s',
    noPermission = 'You do not have permission to use this command.',
    playerNotFound = 'Player not found.',
    selfCommend = 'You cannot commend yourself.',
    commandUsage = 'Usage: /%s [player_id] [reason]'
}

Config.ChatAnnouncement = {
    enabled = true,
    message = '^3%s^7 has been commended by an admin for ^2%s^7!'
}

Config.Leaderboard = {
    title = 'Top Commended Players',
    maxEntries = 10,
    defaultReason = 'Great roleplay!'
}

Config.DatabaseTable = 'player_commends'