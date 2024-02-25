--[[ FX Information ]]--
fx_version   'cerulean'
lua54        'yes'
game 		 'gta5'

--[[ Resource Information ]]--
name         'esx_dmvschool'
author       'bzv'

shared_script {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/pl.lua',
	'locales/sv.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/en.lua',
	'locales/es.lua',
	'locales/pl.lua',
	'locales/sv.lua',
	'config.lua',
	'client/main.lua'
}


dependencies {
	'es_extended',
	'esx_license'
}
