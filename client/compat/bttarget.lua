local exportPrefix = 'bt-target'
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

local exports = {
  AddCircleZone = function(name,center,radius,options,targetOptions)
    local items = {}
    local globalJobName = false
    if targetOptions.job then
      if tpye(targetOptions.job) == "table" then
        globalJobName = {}
        for k,v in pairs(targetOptions.job) do
          globalJobName[v] = true
        end
      else
        globalJobName[targetOptions.job] = true
      end
    end
    local newGlobalcanInteract = function ()
      local jobName = frameworkCache.data["jobName"]
      if globalJobName and not globalJobName["all"] and not globalJobName[jobName] then
        return false
      end
      if targetOptions.canInteract then
        return targetOptions.canInteract()
      else
        return true
      end
    end

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
      if targetOptions.options[option.index].event then
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

    return mTarget.addPoint(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,center,radius,NewFunction,items,{},GetInvokingResource(),newGlobalcanInteract)
  end,

  AddBoxZone = function(name,center,length,width,options,targetOptions)
    local items = {}
    local globalJobName = false
    if targetOptions.job then
      if tpye(targetOptions.job) == "table" then
        globalJobName = {}
        for k,v in pairs(targetOptions.job) do
          globalJobName[v] = true
        end
      else
        globalJobName[targetOptions.job] = true
      end
    end
    local newGlobalcanInteract = function ()
      local jobName = frameworkCache.data["jobName"]
      if globalJobName and not globalJobName["all"] and not globalJobName[jobName] then
        return false
      end
      if targetOptions.canInteract then
        return targetOptions.canInteract()
      else
        return true
      end
    end

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
      if targetOptions.options[option.index].event then
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

    return mTarget.addInternalBoxZone(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,center,length,width,options,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),newGlobalcanInteract)
  end,

  AddPolyZone = function(name,points,options,targetOptions)
    local items = {}
    local globalJobName = false
    if targetOptions.job then
      if tpye(targetOptions.job) == "table" then
        globalJobName = {}
        for k,v in pairs(targetOptions.job) do
          globalJobName[v] = true
        end
      else
        globalJobName[targetOptions.job] = true
      end
    end
    local newGlobalcanInteract = function ()
      local jobName = frameworkCache.data["jobName"]
      if globalJobName and not globalJobName["all"] and not globalJobName[jobName] then
        return false
      end
      if targetOptions.canInteract then
        return targetOptions.canInteract()
      else
        return true
      end
    end

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
      if targetOptions.options[option.index].event then
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

    return mTarget.addInternalPoly(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,points,options,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),newGlobalcanInteract)
  end,

  AddTargetModel = function(models,targetOptions)
    local items = {}
    local globalJobName = false
    if targetOptions.job then
      if tpye(targetOptions.job) == "table" then
        globalJobName = {}
        for k,v in pairs(targetOptions.job) do
          globalJobName[v] = true
        end
      else
        globalJobName[targetOptions.job] = true
      end
    end
    local newGlobalcanInteract = function ()
      local jobName = frameworkCache.data["jobName"]
      if globalJobName and not globalJobName["all"] and not globalJobName[jobName] then
        return false
      end
      if targetOptions.canInteract then
        return targetOptions.canInteract()
      else
        return true
      end
    end

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
      if targetOptions.options[option.index].event then
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

    local name = 'bt_model_' .. randomNameId

    return mTarget.addModels(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,models,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),newGlobalcanInteract)
  end,

  AddEntityZone = function(name,entity,options,targetOptions)
    local items = {}
    local globalJobName = false
    if targetOptions.job then
      if tpye(targetOptions.job) == "table" then
        globalJobName = {}
        for k,v in pairs(targetOptions.job) do
          globalJobName[v] = true
        end
      else
        globalJobName[targetOptions.job] = true
      end
    end
    local newGlobalcanInteract = function ()
      local jobName = frameworkCache.data["jobName"]
      if globalJobName and not globalJobName["all"] and not globalJobName[jobName] then
        return false
      end
      if targetOptions.canInteract then
        return targetOptions.canInteract()
      else
        return true
      end
    end

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
      if targetOptions.options[option.index].event then
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
      return mTarget.addNetEnt(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),newGlobalcanInteract)
    else
      return mTarget.addLocalEnt(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,NewFunction,items,{},GetInvokingResource(),newGlobalcanInteract)
    end
  end,

  RemoveZone = function(name)
    return mTarget.removeTarget(name)
  end
}

for k,v in pairs(exports) do
  AddEventHandler(getExportEventName(k),function(cb)
    cb(v)
  end)
end
