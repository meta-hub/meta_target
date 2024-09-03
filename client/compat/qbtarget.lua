local exportPrefix = 'qb-target'
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

local addedInfo = {
  entities = {},
  models = {},
}
local randomNameId = 0

local exports = {
  AddCircleZone = function(name,center,radius,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end
        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    return mTarget.addPoint(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,center,radius,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  AddBoxZone = function(name,center,length,width,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end
    return mTarget.addInternalBoxZone(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,center,length,width,options,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  AddPolyZone = function(name,points,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    return mTarget.addInternalPoly(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,points,options,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  AddComboZone = function(zones,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_czone_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    return mTarget.addInternalPoly(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,points,options,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  AddEntityZone = function(name,entity,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    if NetworkGetEntityIsNetworked(entity) then
      return mTarget.addNetEnt(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    else
      return mTarget.addLocalEnt(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    end
  end,

  AddTargetModel = function(models,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    randomNameId = randomNameId + 1
    local name = 'qb_model_' .. randomNameId
    if type(models) == "table" then
      for _, model in pairs(models) do
        local finalName = name .. '_' .. model
        addedInfo.models[model] = finalName
        mTarget.addModel(finalName,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,model,targetOptions.distance or false, NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
      end
    else
      addedInfo.models[models] = name
      return mTarget.addModel(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,models,targetOptions.distance or false, NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    end
  end,

  AddTargetBone = function(bones,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_bone_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    return mTarget.addModelBone(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,bones,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  AddTargetEntity = function(entities,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    randomNameId = randomNameId + 1
    local name = 'qb_entity_' .. randomNameId
    if type(entities) == "table" then
      for _, entity in pairs(entities) do
        local finalName = name .. '_' .. entity
        addedInfo.entities[entity] = finalName
        mTarget.addLocalEnt(finalName,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
      end
    else
      addedInfo.entities[entities] = name
      mTarget.addLocalEnt(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entities,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
    end
  end,

  Ped = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_ped_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    return mTarget.addPed(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  Vehicle = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_vehicle_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    return mTarget.addVehicle(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  Object = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_object_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    return mTarget.addObject(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  Player = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      local oldCanIntract = t.canInteract
      local jobName = t.job
      local gangName = t.gang
      local newCanIntract = function(target,option,pos,entity,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        if jobName or gangName then
          if not frameworkCache.data["jobName"] then
            return false
          elseif type(jobName) == "string" and jobName ~= "all" and frameworkCache.data["jobName"] ~= jobName then
            return false
          elseif type(jobName) == "table" and not jobName["all"] and (not jobName[frameworkCache.data["jobName"]] or jobName[frameworkCache.data["jobName"]] > frameworkCache.data["jobGrade"]) then
            return false
          -- elseif not frameworkCache.data["gangName"] or frameworkCache.data["gangName"] < gangName then
          --   return false
          end

        end
        if oldCanIntract then
          return oldCanIntract(entity, targetDist, t)
        end
        return true
      end
      table.insert(items,{
        label = t.label,
        index = _,
        canInteract = newCanIntract,
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_player_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      elseif targetOptions.options[option.index].event then
        local data = targetOptions.options[option.index]
        data.entity = entity
        data.distance = targetOptions.distance or Config.defaultRadius
        if targetOptions.options[option.index].type == "client" then
          TriggerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "server" then
          TriggerServerEvent(targetOptions.options[option.index].event, data)
        elseif targetOptions.options[option.index].type == "command" then
          ExecuteCommand(targetOptions.options[option.index].event)
        elseif targetOptions.options[option.index].type == "qbcommand" then
          TriggerServerEvent('QBCore:CallCommand', targetOptions.options[option.index].event, data)
        else
          TriggerEvent(targetOptions.options[option.index].event, data)
        end
      end
    end

    return mTarget.addPlayer(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),targetOptions.canInteract)
  end,

  RemoveZone = function(name)
    return mTarget.removeTarget(name)
  end,

  RemoveTargetBone = function(name)
    return mTarget.removeTarget(name)
  end,

  RemoveTargetEntity = function(names)
    local removeList = {}
    names = type(names) == 'table' and names or {names}
    for k,name in pairs(names) do
      if addedInfo.entities[name] then
        table.insert(removeList, addedInfo.entities[name])
        for k,v in pairs(addedInfo.entities) do
          if v == name then
            addedInfo.entities[k] = nil
          end
        end
      else
        for k,v in pairs(addedInfo.entities) do
          if name == v then
            table.insert(removeList, k)
            addedInfo.entities[k] = nil
          end
        end
      end
    end
    mTarget.removeTarget(table.unpack(removeList))
  end,

  RemoveTargetModel = function(names)
    local removeList = {}
    names = type(names) == 'table' and names or {names}
    for k,name in pairs(names) do
      if addedInfo.models[name] then
        table.insert(removeList, addedInfo.models[name])
        for k,v in pairs(addedInfo.models) do
          if v == name then
            addedInfo.models[k] = nil
          end
        end
      else
        for k,v in pairs(addedInfo.models) do
          if name == v then
            table.insert(removeList, k)
            addedInfo.models[k] = nil
          end
        end
      end
    end
    mTarget.removeTarget(table.unpack(removeList))
  end,

  RemovePed = function(name)
    return mTarget.removeTarget(name)
  end,

  RemoveVehicle = function(name)
    return mTarget.removeTarget(name)
  end,

  RemoveObject = function(name)
    return mTarget.removeTarget(name)
  end,

  RemovePlayer = function(name)
    return mTarget.removeTarget(name)
  end,
}

for k,v in pairs(exports) do
  AddEventHandler(getExportEventName(k),function(cb)
    cb(v)
  end)
end
