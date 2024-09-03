-- its full mess because i was testing all the functions and events from this file inside another resource but i think its better to be here for
-- better understanding of the code


-- local ox_target = exports.ox_target
-- print("start target reg")
-- AddEventHandler('ox_target:debug', function(data)
--   if data.entity and GetEntityType(data.entity) > 0 then
--       data.archetype = GetEntityArchetypeName(data.entity)
--       data.model = GetEntityModel(data.entity)
--   end

--   print(ESX.DumpTable(data, 1, true))
-- -- print(json.encode(data, {indent=true}))
-- end)
-- 1

-- ox_target:addGlobalObject({
--   {
--       name = 'debug_object',
--       event = 'ox_target:debug',
--       icon = 'fa-solid fa-bong',
--       label = locale('debug_object'),
--   },
--   {
--       name = 'debug_object2',
--       event = 'ox_target:debug',
--       icon = 'fa-solid fa-bong',
--       label = locale('debug_object2'),
--   },
-- })

-- RegisterCommand('removeTarget', function()
--   print(`object`, {'debug_object'})
--   exports.ox_target:removeGlobalObject({'debug_object','debug_object82'})
-- end)


-- local propNetId = false
-- CreateThread(function ()
--   -- make one prop in network and get netID in player coords
--   local playerPed = PlayerPedId()
--   local playerCoords = GetEntityCoords(playerPed)
--   lib.requestModel(`prop_cs_beer_bot_01`)
--   print("is model loaded", HasModelLoaded(`prop_cs_beer_bot_01`))
--   local prop = CreateObject(`prop_cs_beer_bot_01`, playerCoords.x,playerCoords.y,playerCoords.z, true, false, false)
--   SetEntityAsMissionEntity(prop, true, true)
--   FreezeEntityPosition(prop, true)
--   propNetId = NetworkGetNetworkIdFromEntity(prop)
--   exports.ox_target:addEntity(propNetId, {
--     {
--         name = 'debug_netEnt',
--         event = 'ox_target:debug',
--         icon = 'fa-solid fa-beer',
--         label = locale('debug_netEnt'),
--     },
--     {
--         name = 'debug_netEnt2',
--         event = 'ox_target:debug',
--         icon = 'fa-solid fa-beer',
--         label = locale('debug_netEnt2'),
--     },
--   })
-- end)

-- RegisterCommand('removeTarget', function()
--   print(propNetId, {'debug_netEnt'})
--   exports.ox_target:removeEntity(propNetId, {'debug_netEnt','debug_netEnt2'})
-- end)

-- AddEventHandler('onResourceStop', function(resource)
--   if resource == GetCurrentResourceName() then
--     if propNetId then
--       local prop = NetworkGetEntityFromNetworkId(propNetId)
--       print('prop', prop, "exist", DoesEntityExist(prop))
--       if DoesEntityExist(prop) then
--         print(prop)
--         DeleteEntity(prop)
--       end
--     end
--   end
-- end)

-- now addLocalEntity
-- local entityId = false
-- CreateThread(function ()
--   local playerPed = PlayerPedId()
--   local playerCoords = GetEntityCoords(playerPed)
--   lib.requestModel(`prop_cs_beer_bot_01`)
--   print("is model loaded", HasModelLoaded(`prop_cs_beer_bot_01`))
--   entityId = CreateObject(`prop_cs_beer_bot_01`, playerCoords.x,playerCoords.y,playerCoords.z, true, false, false)
--   SetEntityAsMissionEntity(entityId, true, true)
--   FreezeEntityPosition(entityId, true)
--   print("new entity", entityId)
--   exports.ox_target:addLocalEntity(entityId, {
--     {
--         name = 'debug_entity',
--         event = 'ox_target:debug',
--         icon = 'fa-solid fa-beer',
--         label = locale('debug_entity'),
--     },
--     {
--         name = 'debug_entity2',
--         event = 'ox_target:debug',
--         icon = 'fa-solid fa-beer',
--         label = locale('debug_entity2'),
--     },
--   })
-- end)

-- RegisterCommand('removeTarget', function()
--   print(entityId, {'debug_entity'})
--   exports.ox_target:removeLocalEntity(entityId, {'debug_entity','debug_entity2'})
-- end)

-- AddEventHandler('onResourceStop', function(resource)
--   if resource == GetCurrentResourceName() then
--     print("resource stop",entityId)
--     if entityId then
--       print('entity', entityId, "exist", DoesEntityExist(entityId))
--       if DoesEntityExist(entityId) then
--         print(entityId)
--         DeleteEntity(entityId)
--       end
--     end
--   end
-- end)


-- ox_target:addModel(`police`, {
--   {
--       name = 'debug_model',
--       event = 'ox_target:debug',
--       icon = 'fa-solid fa-handcuffs',
--       label = locale('debug_police_car'),
--   },
--   {
--       name = 'debug_model2',
--       event = 'ox_target:debug',
--       icon = 'fa-solid fa-handcuffs',
--       label = locale('debug_police_car2'),
--   },
-- })

-- RegisterCommand('removeTarget', function()
--   print(`police`, {'debug_model'})
--   exports.ox_target:removeModel(`police`, {'debug_model','debug_model2'})
-- end)

-- ox_target:addGlobalPed({
--   {
--       name = 'ped',
--       event = 'ox_target:debug',
--       icon = 'fa-solid fa-male',
--       label = locale('debug_ped'),
--   },
--   {
--       name = 'ped2',
--       event = 'ox_target:debug',
--       icon = 'fa-solid fa-male',
--       label = locale('debug_ped2'),
--   },
-- })

-- RegisterCommand('removeTarget', function()
--   print(`ped`, {'ped'})
--   exports.ox_target:removeGlobalPed({'ped','ped2'})
-- end)

-- ox_target:addSphereZone({
--   coords = vec3(440.5363, -1015.666, 28.85637),
--   radius = 3,
--   debug = true,
--   drawSprite = true,
--   options = {
--       {
--           name = 'debug_sphere',
--           event = 'ox_target:debug',
--           icon = 'fa-solid fa-circle',
--           label = locale('debug_sphere'),
--       }
--   }
-- })


-- ox_target:addBoxZone({
--   coords = vec3(442.5363, -1017.666, 28.85637),
--   size = vec3(3, 3, 3),
--   rotation = 45,
--   debug = true,
--   drawSprite = true,
--   options = {
--       {
--           name = 'debug_box',
--           event = 'ox_target:debug',
--           icon = 'fa-solid fa-cube',
--           label = locale('debug_box'),
--       }
--   }
-- })

-- local plZoneId = ox_target:addPolyZone({
--   points = {
--     vec(413.8, -1026.1, 29),
--     vec(411.6, -1023.1, 29),
--     vec(412.2, -1018.0, 29),
--     vec(417.2, -1016.3, 29),
--     vec(422.3, -1020.0, 29),
--     vec(426.8, -1015.9, 29),
--     vec(431.8, -1013.0, 29),
--     vec(437.3, -1018.4, 29),
--     vec(432.4, -1027.2, 29),
--     vec(424.7, -1023.5, 29),
--     vec(420.0, -1030.2, 29),
--     vec(409.8, -1028.4, 29),
--   },
--   debug = true,
--   thickness = 3,
--   options = {
--       {
--           name = 'debug_poly',
--           event = 'ox_target:debug',
--           icon = 'fa-solid fa-cube',
--           label = locale('debug_poly'),
--       }
--   }
-- })

-- RegisterCommand('removeTarget', function()
--   print(plZoneId)
--   exports.ox_target:removeZone(plZoneId)
-- end)


-- ox_target:addGlobalVehicle({
--   {
--       name = 'debug_vehicle',
--       event = 'ox_target:debug',
--       icon = 'fa-solid fa-car',
--       label = locale('debug_vehicle'),
--   },
--   {
--       name = 'debug_vehicle2',
--       event = 'ox_target:debug',
--       icon = 'fa-solid fa-car',
--       label = locale('debug_vehicle2'),
--   },
-- })

-- RegisterCommand('removeTarget', function()
--   print(`vehicle`, {'debug_vehicle'})
--   exports.ox_target:removeGlobalVehicle({'debug_vehicle','debug_vehicle2'})
-- end)


-- print("end target reg")