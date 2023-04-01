local exportPrefix = 'qb-target'

local function getExportEventName(name)
  return string.format('__cfx_export_%s_%s',exportPrefix,name)
end

local randomNameId = 0

local exports = {
  AddCircleZone = function(name,center,radius,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end

    return mTarget.addPoint(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,center,radius,false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  AddBoxZone = function(name,center,length,width,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end

    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end
    return mTarget.addInternalBoxZone(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,center,length,width,options,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  AddPolyZone = function(name,points,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end

    return mTarget.addInternalPoly(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,points,options,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  AddComboZone = function(zones,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_czone_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end

    return mTarget.addInternalPoly(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,points,options,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  AddEntityZone = function(name,entity,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end

    if NetworkGetEntityIsNetworked(entity) then
      return mTarget.addNetEnt(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
    else
      return mTarget.addLocalEnt(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
    end
  end,    

  AddTargetModel = function(models,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end
    
    randomNameId = randomNameId + 1
    local name = 'qb_model_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end

    return mTarget.addModels(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,models,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  AddTargetBone = function(bones,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_bone_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end
    
    return mTarget.addModelBone(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,bones,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  AddTargetEntity = function(entities,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_entity_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end
    
    return mTarget.addLocalEnt(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,entities,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  Ped = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end
    
    randomNameId = randomNameId + 1
    local name = 'qb_ped_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end

    return mTarget.addPed(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  Vehicle = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_vehicle_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end
    
    return mTarget.addVehicle(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  Object = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_object_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end
    
    return mTarget.addObject(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,

  Player = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        index = _,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'qb_player_' .. randomNameId
    local NewFunction = function(target,option,entity)
      if targetOptions.options[option.index].action then
        targetOptions.options[option.index].action(entity)
      end
    end

    return mTarget.addPlayer(name,targetOptions.title or targetOptions.options[1].label or name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,targetOptions.options[1].action and NewFunction or false,items,{},GetInvokingResource(),targetOptions.canShow)
  end,               

  RaycastCamera = function(flag, playerCoords)
    local hit,endPos,entityHit = s2w.get(flag or -1,playerPed,0)
    local distance = #(endPos - (playerCoords or GetEntityCoords(playerPed)))
    local entityType = entityHit and GetEntityType(entityHit)

    if entityType == 0 and pcall(GetEntityModel, entityHit) then
      entityType = 3
    end

    return endPos, distance, entityHit, entityType or 0
  end,
  
  RemoveZone = function(name)
    return mTarget.removeTarget(name)
  end,

  RemoveTargetBone = function(name)
    return mTarget.removeTarget(name)
  end,  

  RemoveTargetEntity = function(name)
    return mTarget.removeTarget(name)
  end,

  RemoveTargetModel = function(name)
    return mTarget.removeTarget(name)
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
