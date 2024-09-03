Config = {
  defaultRadius = 50.0,
  zoneCreatorCore = 'ox_lib', -- 'PolyZone' or 'ox_lib'
  -- if you enter ox_lib it will try to convert PolyZone to ox_lib automaticly and just use ox_lib underhood nothing changes
  -- btw i need more coding for ox_target to work with this new logic
  -- as far as i know both are good but ox_lib should have better performance due using glm lib but PolyZone doing all vannila
  -- i think better use ox_lib for better compatibility with ox_target compatibility part of reousrce

  colors = {
    -- note: dont edit key/index, aligns with html
    ['--eye-color-active']  = 'rgba(84, 140, 98, 1)',
    ['--eye-color']         = 'rgba(255,255,255, 0.7)',
    ['--title-color']       = 'rgba(84, 140, 98, 1)',
    ['--text-color']        = 'rgba(255,255,255, 0.8)',
  }
}