fx_version 'adamant'
game {'gta5','rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

github 'https://github.com/meta-hub/meta-target'
version '1.1.0'

lua54 'yes'
use_fxv2_oal 'yes'

ui_page 'nui/index.html'

client_scripts {
  "@ox_lib/init.lua",
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/CircleZone.lua',

  'config.lua',
  'client/s2w.lua',
  'client/main.lua',
  'client/compat/*.lua',
  'client/compat/framework/*.lua',
}

files {
  'nui/index.html',
  'lib/target.lua'
}

dependencies {
  'PolyZone',
  'ox_lib',
}

provide 'bt-target'
provide 'fivem-target'
provide 'qtarget'
provide 'qb-target'
provide 'ox_target'