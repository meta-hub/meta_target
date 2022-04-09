local exportPrefix = 'qtarget'

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
        onSelect = t.event
      })
    end

    return mTarget.addPoint(name,name:upper(),targetOptions.options[1].icon,center,radius,false,items,{},GetInvokingResource())
  end,

  AddBoxZone = function(name,center,length,width,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    return mTarget.addInternalBoxZone(name,name:upper(),targetOptions.options[1].icon,center,length,width,options,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  AddPolyZone = function(name,points,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    return mTarget.addInternalPoly(name,name:upper(),targetOptions.options[1].icon,points,options,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  AddComboZone = function(zones,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'q_czone_' .. randomNameId

    return mTarget.addInternalPoly(name,name:upper(),targetOptions.options[1].icon,points,options,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  AddEntityZone = function(name,entity,options,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    if NetworkGetEntityIsNetworked(entity) then
      return mTarget.addNetEnt(name,name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,false,items,{},GetInvokingResource())
    else
      return mTarget.addLocalEnt(name,name:upper(),targetOptions.options[1].icon,entity,targetOptions.distance or false,false,items,{},GetInvokingResource())
    end
  end,    

  AddTargetModel = function(models,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end
    
    randomNameId = randomNameId + 1
    local name = 'q_model_' .. randomNameId

    return mTarget.addModels(name,name:upper(),targetOptions.options[1].icon,models,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  AddTargetBone = function(bones,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'q_bone_' .. randomNameId
    
    return mTarget.addModelBone(name,name:upper(),targetOptions.options[1].icon,bones,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  AddTargetEntity = function(entities,targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'q_entity_' .. randomNameId
    
    return mTarget.addLocalEnt(name,name:upper(),targetOptions.options[1].icon,entities,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  Ped = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end
    
    randomNameId = randomNameId + 1
    local name = 'q_ped_' .. randomNameId

    return mTarget.addPed(name,name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  Vehicle = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'q_vehicle_' .. randomNameId
    
    return mTarget.addVehicle(name,name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  Object = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'q_object_' .. randomNameId
    
    return mTarget.addObject(name,name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,false,items,{},GetInvokingResource())
  end,

  Player = function(targetOptions)
    local items = {}

    for _,t in ipairs(targetOptions.options) do
      table.insert(items,{
        label = t.label,
        onSelect = t.event
      })
    end

    randomNameId = randomNameId + 1
    local name = 'q_player_' .. randomNameId

    return mTarget.addPlayer(name,name:upper(),targetOptions.options[1].icon,targetOptions.distance or false,false,items,{},GetInvokingResource())
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
