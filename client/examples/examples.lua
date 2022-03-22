local function onSelect(t,o)
  print(t.id,o.name)
end

-- local mTarget = exports.meta_target

-- if GetGameName() == 'redm' then
--   local models = {'p_barberchair03x','p_barberchair01x','p_barberchair02x'}

--   mTarget:addModels('test','Test', 'fas fa-car', models, 10.0, onSelect,{
--     {
--       name = 'do_something',
--       label = 'Do Something'
--     }
--   })
-- else
--   local targetModel = 'buffalo'

--   local bones = {
--     'door_dside_f',
--     'door_pside_f'
--   }

--   mTarget:addModelBones('my_buffalo_target_doors', 'buffalo', 'fas fa-car', targetModel, bones, 1.0, onSelect, {
--     {
--       name = 'lock_door',
--       label = 'Lock Door'
--     }
--   })

--   mTarget:addModelBone('my_buffalo_target_trunk', 'buffalo', 'fas fa-car', targetModel, 'boot', 2.0, onSelect, {
--     {
--       name = 'lock_trunk',
--       label = 'Lock Trunk'
--     }
--   })

--   mTarget:addModelBone('my_buffalo_target_hood', 'buffalo', 'fas fa-car', targetModel, 'bonnet', 2.0, onSelect, {
--     {
--       name = 'lock_hood',
--       label = 'Lock Hood'
--     }
--   })
-- end


local models = {
  "prop_cs_dumpster_01a",
  "p_dumpster_t",
  "prop_snow_dumpster_01",
  "prop_dumpster_01a",
  "prop_dumpster_02a",
  "prop_dumpster_02b",
  "prop_dumpster_3a",
  "prop_dumpster_4a",
  "prop_dumpster_4b",
}

exports["meta_target"]:addModels({
  id = "dumpsters",
  title = "Dumpster",
  icon = "fas fa-dumpster",
  models = models,
  radius = 2,
  onSelect = onSelect,
  items = {
    {
      name = "search_dumpster",
      label = "Search Dumpster"
    }
  }
})