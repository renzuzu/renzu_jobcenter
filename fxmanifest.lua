fx_version 'cerulean' 
lua54 'yes'
game 'gta5' 
--
ui_page {
    'web/index.html',
}
shared_script '@renzu_shield/init.lua'


shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
	'skins.lua',
}
client_scripts {
	'client/main.lua'
}

server_scripts {
	'server/main.lua'
}

files {
	'web/index.html',
	'web/script.js',
	'web/style.css',
	'web/images/*.png',
}