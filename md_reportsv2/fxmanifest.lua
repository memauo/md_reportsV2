fx_version 'cerulean'
game 'gta5'

Author 'Memauo MD DEV'
Description 'Report Menu V2'

client_scripts {
    'customize/client.lua',
    'client.lua'
}

server_scripts {
    'customize/server.lua',
    'server.lua'
}
shared_scripts {
    'config.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/assets/*'
}

shared_scripts {
    '@ox_lib/init.lua'
}