fx_version 'cerulean'
game 'gta5'

name 'twilight-commend'
description 'QBCore Admin Commending System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'oxmysql'
}

lua54 'yes'