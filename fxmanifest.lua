fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
use_fxv2_oal 'yes'

ui_page 'nui/index.html'

client_scripts {
  '@redm-ulib/lib/matrix.lua',
  '@redm-ulib/lib/s2w.lua',
  '@redm-ulib/lib/controls.lua',
  '@redm-ulib/lib/playerdata.lua',
  
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/EntityZone.lua',
  '@PolyZone/CircleZone.lua',
  '@PolyZone/ComboZone.lua',

  'config.lua',
  'client/main.lua',

}

files {
  'nui/index.html',
  'lib/target.lua'
}

dependencies {
  'redm-ulib',
  'PolyZone'
}
