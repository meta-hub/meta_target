local exportPrefix = 'ox_target'
local currentResource = GetCurrentResourceName()
local frameworkCache = {loaded = false, data = {}}

-- framework part
AddEventHandler(currentResource .. ":frameworkReady", function(startingData)
  frameworkCache.loaded = true
  for k,v in pairs(startingData) do
    frameworkCache.data[k] = v
  end
end)
AddEventHandler(currentResource .. ":frameworkUnLoad", function()
  frameworkCache.loaded = false
  frameworkCache.data = {}
end)

AddEventHandler(currentResource .. ":frameworkChange", function(newData)
  if not frameworkCache.loaded then return end
  for k,v in pairs(newData) do
    frameworkCache.data[k] = v
  end
end)

local function getExportEventName(name)
  return string.format('__cfx_export_%s_%s',exportPrefix,name)
end

local randomNameId = 0

-- btw i got list of functions from here https://overextended.dev/ox_target/Functions/Client
-- and read those parts i need from the source code and do tests
-- if it have issue or miss something tell me
local exports = {
  addGlobalObject = function(targetOptions)
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    local maxDistance = 0
    for _,t in ipairs(targetOptions) do
      if t.distance and t.distance > maxDistance then
        maxDistance = t.distance
      end
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if t.distance and targetDist > t.distance then
          return false
        end
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          -- i think better to remake this part as work with addNetEntBones and addLocalEntBone
          local bone = modelHash and t.bones or nil
          if bone then
            if type(bone) == "string" then
              local boneId = GetEntityBoneIndexByName(entity, bone)

              if boneId ~= -1 and #(endPos - GetEntityBonePosition_2(entity, boneId)) <= 2 then
                bone = boneId
              else
                return false
              end
            else
              local closestBone, boneDistance
              for j = 1, #bone do
                local boneId = GetEntityBoneIndexByName(entity, bone[j])
                if boneId ~= -1 then
                  local dist = #(endPos - GetEntityBonePosition_2(entity, boneId))
                  if dist <= (boneDistance or 1) then
                    closestBone = boneId
                    boneDistance = dist
                  end
                end
              end
              if closestBone then
                bone = closestBone
              else
                return false
              end
            end
          end
          return oldCanIntract(entity, targetDist, pos, t.name, bone)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        bones = t.bones,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_object_' .. randomNameId
    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    return mTarget.addObject(name,targetOptions[1].label or name:upper(),targetOptions[1].icon,maxDistance > 0 and maxDistance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  addGlobalPed = function(targetOptions)
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    local maxDistance = 0
    for _,t in ipairs(targetOptions) do
      if t.distance and t.distance > maxDistance then
        maxDistance = t.distance
      end
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if t.distance and targetDist > t.distance then
          return false
        end
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          -- i think better to remake this part as work with addNetEntBones and addLocalEntBone
          local bone = modelHash and t.bones or nil
          if bone then
            if type(bone) == "string" then
              local boneId = GetEntityBoneIndexByName(entity, bone)

              if boneId ~= -1 and #(endPos - GetEntityBonePosition_2(entity, boneId)) <= 2 then
                bone = boneId
              else
                return false
              end
            else
              local closestBone, boneDistance
              for j = 1, #bone do
                local boneId = GetEntityBoneIndexByName(entity, bone[j])
                if boneId ~= -1 then
                  local dist = #(endPos - GetEntityBonePosition_2(entity, boneId))
                  if dist <= (boneDistance or 1) then
                    closestBone = boneId
                    boneDistance = dist
                  end
                end
              end
              if closestBone then
                bone = closestBone
              else
                return false
              end
            end
          end
          return oldCanIntract(entity, targetDist, pos, t.name, bone)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        bones = t.bones,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_ped_' .. randomNameId
    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    return mTarget.addPed(name,targetOptions[1].label or name:upper(),targetOptions[1].icon,maxDistance > 0 and maxDistance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  addGlobalPlayer = function(targetOptions)
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    local maxDistance = 0
    for _,t in ipairs(targetOptions) do
      if t.distance and t.distance > maxDistance then
        maxDistance = t.distance
      end
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if t.distance and targetDist > t.distance then
          return false
        end
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          -- i think better to remake this part as work with addNetEntBones and addLocalEntBone
          local bone = modelHash and t.bones or nil
          if bone then
            if type(bone) == "string" then
              local boneId = GetEntityBoneIndexByName(entity, bone)

              if boneId ~= -1 and #(endPos - GetEntityBonePosition_2(entity, boneId)) <= 2 then
                bone = boneId
              else
                return false
              end
            else
              local closestBone, boneDistance
              for j = 1, #bone do
                local boneId = GetEntityBoneIndexByName(entity, bone[j])
                if boneId ~= -1 then
                  local dist = #(endPos - GetEntityBonePosition_2(entity, boneId))
                  if dist <= (boneDistance or 1) then
                    closestBone = boneId
                    boneDistance = dist
                  end
                end
              end
              if closestBone then
                bone = closestBone
              else
                return false
              end
            end
          end
          return oldCanIntract(entity, targetDist, pos, t.name, bone)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        bones = t.bones,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_player_' .. randomNameId
    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    return mTarget.addPlayer(name,targetOptions[1].label or name:upper(),targetOptions[1].icon,maxDistance > 0 and maxDistance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  addGlobalVehicle = function(targetOptions)
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    local maxDistance = 0
    for _,t in ipairs(targetOptions) do
      if t.distance and t.distance > maxDistance then
        maxDistance = t.distance
      end
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if t.distance and targetDist > t.distance then
          return false
        end
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          -- i think better to remake this part as work with addNetEntBones and addLocalEntBone
          local bone = modelHash and t.bones or nil
          if bone then
            if type(bone) == "string" then
              local boneId = GetEntityBoneIndexByName(entity, bone)

              if boneId ~= -1 and #(endPos - GetEntityBonePosition_2(entity, boneId)) <= 2 then
                bone = boneId
              else
                return false
              end
            else
              local closestBone, boneDistance
              for j = 1, #bone do
                local boneId = GetEntityBoneIndexByName(entity, bone[j])
                if boneId ~= -1 then
                  local dist = #(endPos - GetEntityBonePosition_2(entity, boneId))
                  if dist <= (boneDistance or 1) then
                    closestBone = boneId
                    boneDistance = dist
                  end
                end
              end
              if closestBone then
                bone = closestBone
              else
                return false
              end
            end
          end
          return oldCanIntract(entity, targetDist, pos, t.name, bone)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        bones = t.bones,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_vehicle_' .. randomNameId
    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    return mTarget.addVehicle(name,targetOptions[1].label or name:upper(),targetOptions[1].icon,maxDistance > 0 and maxDistance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  addModel = function(models, targetOptions)
    if type(models) ~= "table" then
      models = {models}
    end
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    local maxDistance = 0
    for _,t in ipairs(targetOptions) do
      if t.distance and t.distance > maxDistance then
        maxDistance = t.distance
      end
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if t.distance and targetDist > t.distance then
          return false
        end
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          -- i think better to remake this part as work with addNetEntBones and addLocalEntBone
          local bone = modelHash and t.bones or nil
          if bone then
            if type(bone) == "string" then
              local boneId = GetEntityBoneIndexByName(entity, bone)

              if boneId ~= -1 and #(endPos - GetEntityBonePosition_2(entity, boneId)) <= 2 then
                bone = boneId
              else
                return false
              end
            else
              local closestBone, boneDistance
              for j = 1, #bone do
                local boneId = GetEntityBoneIndexByName(entity, bone[j])
                if boneId ~= -1 then
                  local dist = #(endPos - GetEntityBonePosition_2(entity, boneId))
                  if dist <= (boneDistance or 1) then
                    closestBone = boneId
                    boneDistance = dist
                  end
                end
              end
              if closestBone then
                bone = closestBone
              else
                return false
              end
            end
          end
          return oldCanIntract(entity, targetDist, pos, t.name, bone)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        bones = t.bones,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_model_' .. randomNameId

    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    return mTarget.addModels(name,targetOptions[1].label or name:upper(),targetOptions[1].icon,models,maxDistance > 0 and maxDistance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  addEntity = function(netIds, targetOptions)
    if type(netIds) ~= "table" then
      netIds = {netIds}
    end
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    local maxDistance = 0
    for _,t in ipairs(targetOptions) do
      if t.distance and t.distance > maxDistance then
        maxDistance = t.distance
      end
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if t.distance and targetDist > t.distance then
          return false
        end
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          -- i think better to remake this part as work with addNetEntBones and addLocalEntBone
          local bone = modelHash and t.bones or nil
          if bone then
            if type(bone) == "string" then
              local boneId = GetEntityBoneIndexByName(entity, bone)

              if boneId ~= -1 and #(endPos - GetEntityBonePosition_2(entity, boneId)) <= 2 then
                bone = boneId
              else
                return false
              end
            else
              local closestBone, boneDistance
              for j = 1, #bone do
                local boneId = GetEntityBoneIndexByName(entity, bone[j])
                if boneId ~= -1 then
                  local dist = #(endPos - GetEntityBonePosition_2(entity, boneId))
                  if dist <= (boneDistance or 1) then
                    closestBone = boneId
                    boneDistance = dist
                  end
                end
              end
              if closestBone then
                bone = closestBone
              else
                return false
              end
            end
          end
          return oldCanIntract(entity, targetDist, pos, t.name, bone)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        bones = t.bones,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_net_entities_' .. randomNameId

    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    for _, netId in pairs(netIds) do
      local finalName = name .. '_' .. netId
      mTarget.addNetEnt(finalName,targetOptions[1].label or name:upper(),targetOptions[1].icon,netId,maxDistance > 0 and maxDistance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    end
  end,

  addLocalEntity = function(entities, targetOptions)
    if type(entities) ~= "table" then
      entities = {entities}
    end
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    local maxDistance = 0
    for _,t in ipairs(targetOptions) do
      if t.distance and t.distance > maxDistance then
        maxDistance = t.distance
      end
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if t.distance and targetDist > t.distance then
          return false
        end
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          -- i think better to remake this part as work with addNetEntBones and addLocalEntBone
          local bone = modelHash and t.bones or nil
          if bone then
            if type(bone) == "string" then
              local boneId = GetEntityBoneIndexByName(entity, bone)

              if boneId ~= -1 and #(endPos - GetEntityBonePosition_2(entity, boneId)) <= 2 then
                bone = boneId
              else
                return false
              end
            else
              local closestBone, boneDistance
              for j = 1, #bone do
                local boneId = GetEntityBoneIndexByName(entity, bone[j])
                if boneId ~= -1 then
                  local dist = #(endPos - GetEntityBonePosition_2(entity, boneId))
                  if dist <= (boneDistance or 1) then
                    closestBone = boneId
                    boneDistance = dist
                  end
                end
              end
              if closestBone then
                bone = closestBone
              else
                return false
              end
            end
          end
          return oldCanIntract(entity, targetDist, pos, t.name, bone)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        bones = t.bones,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_local_entities_' .. randomNameId

    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    for _, entity in pairs(entities) do
      local finalName = name .. '_' .. entity
      mTarget.addLocalEnt(finalName,targetOptions[1].label or name:upper(),targetOptions[1].icon,entity,maxDistance > 0 and maxDistance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    end
  end,

  addSphereZone = function(parameters)
    local targetOptions = parameters.options
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    for _,t in ipairs(targetOptions) do
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, pos, t.name)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_zone_sphere_' .. randomNameId

    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    local zoneHanel = mTarget.addInternalSphereZone(name,targetOptions[1].label or name:upper(),targetOptions[1].icon,parameters.coords,parameters.radius,parameters,parameters.range or parameters.radius or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    return zoneHanel.id
  end,

  addBoxZone = function(parameters)
    local targetOptions = parameters.options
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    for _,t in ipairs(targetOptions) do
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, pos, t.name)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_zone_box_' .. randomNameId

    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    local length = parameters.size.x
    local width = parameters.size.y
    local minZ = parameters.coords.z - (parameters.size.z / 2)
    local maxZ = parameters.coords.z + (parameters.size.z / 2)
    parameters.maxZ = maxZ
    parameters.minZ = minZ

    local zoneHanel = mTarget.addInternalBoxZone(name,targetOptions[1].label or name:upper(),targetOptions[1].icon,parameters.coords,length,width,parameters,parameters.radius or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    return zoneHanel.id
  end,

  addPolyZone = function(parameters)
    local targetOptions = parameters.options
    if not targetOptions[1] then
      targetOptions = {targetOptions}
    end
    local items = {}
    for _,t in ipairs(targetOptions) do
      local oldCanIntract = t.canInteract
      local validGroups = t.groups
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if validGroups then
          if not frameworkCache.loaded then return false end
          local isValidGroup = function(groups)
            if type(groups) == "string" then
              return (frameworkCache.data["jobName"] == groups or frameworkCache.data["gangName"] == groups)
            elseif type(groups) == "table" then
              for groupName,groupGrade in pairs(groups) do
                if groupName == "all" then return true end
                if frameworkCache.data["jobName"] == groupName and frameworkCache.data["jobGrade"] >= groupGrade then
                  return true
                end
                -- if frameworkCache.data["gangName"] == groupName then
                --   return true
                -- end
              end
            end
            return false
          end
          if not isValidGroup(validGroups) then
            return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, pos, t.name)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        name = t.name,
        index = _,
        resource = t.resource,
        export = t.export,
        event = t.event,
        serverEvent = t.serverEvent,
        command = t.command,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'ox_zone_poly_' .. randomNameId

    local NewFunction = function(target,option,entity,targetData)
      local reponse = {
        entity = targetData.entityHit,
        distance = targetData.targetDist,
        coords = targetData.pos,
        zone = targetData.zoneHandel,
      }
      local selectedOption = targetOptions[option.index]
      if selectedOption.onSelect then
        selectedOption.onSelect(reponse)
      elseif selectedOption.export then
        exports[selectedOption.resource][selectedOption.export](nil, reponse)
      elseif selectedOption.event then
        TriggerEvent(selectedOption.event, reponse)
      elseif selectedOption.serverEvent then
        reponse.entity = targetData.netId or 0
        TriggerServerEvent(selectedOption.serverEvent, reponse)
      elseif selectedOption.command then
        ExecuteCommand(selectedOption.command)
      end
    end

    local maxZ = parameters.points[1].z
    local minZ = parameters.points[1].z
    for _,point in ipairs(parameters.points) do
      if point.z > maxZ then
        maxZ = point.z
      end
      if point.z < minZ then
        minZ = point.z
      end
    end
    local thickness = parameters.thickness or 0
    parameters.maxZ = maxZ + (thickness / 2)
    parameters.minZ = minZ - (thickness / 2)
    
    local zoneHanel = mTarget.addInternalPoly(name,targetOptions[1].label or name:upper(),targetOptions[1].icon,parameters.points,parameters,parameters.radius or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    return zoneHanel.id
  end,

  removeGlobalObject = function(optionNames)
    if type(optionNames) ~= "table" then
      optionNames = {optionNames}
    end
    local allTargetsByType = mTarget.getTargetByType("object")
    for k,v in ipairs(allTargetsByType) do
      local targetId = v.id
      if string.sub(targetId, 1, 10) == "ox_object_" then
        if #optionNames ~= 0 then
          local optionsNameDict = {}
          for k,v in ipairs(optionNames) do
            optionsNameDict[v] = true
          end
          for i = #v.items, 1, -1 do
            local itemInfo = v.items[i]
            if optionsNameDict[itemInfo.name] then
              table.remove(v.items, i)
            end
          end
        end
        if #optionNames == 0 or #v.items == 0 then
          mTarget.removeTarget(targetId)
        else
          mTarget.updateTargetInfo(targetId, {items = v.items})
        end
      end
    end
  end,

  removeGlobalPed = function(optionNames)
    if type(optionNames) ~= "table" then
      optionNames = {optionNames}
    end
    local allTargetsByType = mTarget.getTargetByType("ped")
    for k,v in ipairs(allTargetsByType) do
      local targetId = v.id
      if string.sub(targetId, 1, 7) == "ox_ped_" then
        if #optionNames ~= 0 then
          local optionsNameDict = {}
          for k,v in ipairs(optionNames) do
            optionsNameDict[v] = true
          end
          for i = #v.items, 1, -1 do
            local itemInfo = v.items[i]
            if optionsNameDict[itemInfo.name] then
              table.remove(v.items, i)
            end
          end
        end
        if #optionNames == 0 or #v.items == 0 then
          mTarget.removeTarget(targetId)
        else
          mTarget.updateTargetInfo(targetId, {items = v.items})
        end
      end
    end
  end,

  removeGlobalPlayer = function(optionNames)
    if type(optionNames) ~= "table" then
      optionNames = {optionNames}
    end
    local allTargetsByType = mTarget.getTargetByType("player")
    for k,v in ipairs(allTargetsByType) do
      local targetId = v.id
      if string.sub(targetId, 1, 10) == "ox_player_" then
        if #optionNames ~= 0 then
          local optionsNameDict = {}
          for k,v in ipairs(optionNames) do
            optionsNameDict[v] = true
          end
          for i = #v.items, 1, -1 do
            local itemInfo = v.items[i]
            if optionsNameDict[itemInfo.name] then
              table.remove(v.items, i)
            end
          end
        end
        if #optionNames == 0 or #v.items == 0 then
          mTarget.removeTarget(targetId)
        else
          mTarget.updateTargetInfo(targetId, {items = v.items})
        end
      end
    end
  end,

  removeGlobalVehicle = function(optionNames)
    if type(optionNames) ~= "table" then
      optionNames = {optionNames}
    end
    local allTargetsByType = mTarget.getTargetByType("vehicle")
    for k,v in ipairs(allTargetsByType) do
      local targetId = v.id
      if string.sub(targetId, 1, 11) == "ox_vehicle_" then
        if #optionNames ~= 0 then
          local optionsNameDict = {}
          for k,v in ipairs(optionNames) do
            optionsNameDict[v] = true
          end
          for i = #v.items, 1, -1 do
            local itemInfo = v.items[i]
            if optionsNameDict[itemInfo.name] then
              table.remove(v.items, i)
            end
          end
        end
        if #optionNames == 0 or #v.items == 0 then
          mTarget.removeTarget(targetId)
        else
          mTarget.updateTargetInfo(targetId, {items = v.items})
        end
      end
    end
  end,

  removeModel = function(models, optionNames)
    if type(models) ~= "table" then
      models = {models}
    end
    if type(optionNames) ~= "table" then
      optionNames = {optionNames}
    end
    local allTargetsByType = mTarget.getTargetByType("model")
    for k,v in ipairs(allTargetsByType) do
      local targetId = v.id
      if string.sub(targetId, 1, 9) == "ox_model_" then
        local modelDict = {}
        for k,v in ipairs(models) do
          local hash = (type(v) == 'number' and v or GetHashKey(v))%0x100000000
          modelDict[hash] = true
        end
        if modelDict[v.hash] then
          if #optionNames ~= 0 then
            local optionsNameDict = {}
            for k,v in ipairs(optionNames) do
              optionsNameDict[v] = true
            end
            for i = #v.items, 1, -1 do
              local itemInfo = v.items[i]
              if optionsNameDict[itemInfo.name] then
                table.remove(v.items, i)
              end
            end
          end
          if #optionNames == 0 or #v.items == 0 then
            mTarget.removeTarget(targetId)
          else
            mTarget.updateTargetInfo(targetId, {items = v.items})
          end
        end
      end
    end
  end,


  removeEntity = function(netIds, optionNames)
    if type(netIds) ~= "table" then
      netIds = {netIds}
    end
    if type(optionNames) ~= "table" then
      optionNames = {optionNames}
    end
    local allTargetsByType = mTarget.getTargetByType("networkEnt")
    for k,v in ipairs(allTargetsByType) do
      local targetId = v.id
      if string.sub(targetId, 1, 16) == "ox_net_entities_" then
        local netIdDict = {}
        for k,v in ipairs(netIds) do
          netIdDict[v] = true
        end
        if netIdDict[v.netId] then
          if #optionNames ~= 0 then
            local optionsNameDict = {}
            for k,v in ipairs(optionNames) do
              optionsNameDict[v] = true
            end
            for i = #v.items, 1, -1 do
              local itemInfo = v.items[i]
              if optionsNameDict[itemInfo.name] then
                table.remove(v.items, i)
              end
            end
          end
          if #optionNames == 0 or #v.items == 0 then
            mTarget.removeTarget(targetId)
          else
            mTarget.updateTargetInfo(targetId, {items = v.items})
          end
        end
      end
    end
  end,


  removeLocalEntity = function(entities, optionNames)
    if type(entities) ~= "table" then
      entities = {entities}
    end
    if type(optionNames) ~= "table" then
      optionNames = {optionNames}
    end
    local allTargetsByType = mTarget.getTargetByType("localEnt")
    for k,v in ipairs(allTargetsByType) do
      local targetId = v.id
      if string.sub(targetId, 1, 18) == "ox_local_entities_" then
        local entityDict = {}
        for k,v in ipairs(entities) do
          entityDict[v] = true
        end
        if entityDict[v.entId] then
          if #optionNames ~= 0 then
            local optionsNameDict = {}
            for k,v in ipairs(optionNames) do
              optionsNameDict[v] = true
            end
            for i = #v.items, 1, -1 do
              local itemInfo = v.items[i]
              if optionsNameDict[itemInfo.name] then
                table.remove(v.items, i)
              end
            end
          end
          if #optionNames == 0 or #v.items == 0 then
            mTarget.removeTarget(targetId)
          else
            mTarget.updateTargetInfo(targetId, {items = v.items})
          end
        end
      end
    end
  end,


  removeZone = function(zoneId)
    local allTargetsByType = mTarget.getTargetByType("polyZone")
    for k,v in ipairs(allTargetsByType) do
      local targetId = v.id
      if type(zoneId) == "number" then
        if v.zoneHandel then
          if v.zoneHandel.id == zoneId then
            mTarget.removeTarget(targetId)
          end
        end
      elseif type(zoneId) == "string" then
        if v.zoneHandel then
          if v.zoneHandel.name == zoneId then
            mTarget.removeTarget(targetId)
          end
        end
      end
    end
  end,
}

for k,v in pairs(exports) do
  AddEventHandler(getExportEventName(k),function(cb)
    cb(v)
  end)
end