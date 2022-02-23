fx_version 'adamant'
game {'gta5','rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
use_fxv2_oal 'yes'

ui_page 'nui/index.html'

client_scripts {  
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',

  'config.lua',
  'client/s2w.lua',
  'client/main.lua',
}

files {
  'nui/index.html',
  'lib/target.lua'
}

dependencies {
  'PolyZone'
}
