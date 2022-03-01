local targets = {}
local activeTargets = {}
local idIndexMap = {}
local isOpen
local cfgSent

local selectMethods = {
  ['function'] = function(t,...)
    return t.onSelect(...)
  end,

  ['table'] = function(t,...)
    return t.onSelect(...)
  end,

  ['string'] = function(t,...)
    return TriggerEvent(t.onSelect,...)
  end
}

local typeChecks = {
  ['point'] = function(target,pos)
    if #(pos - target.pos) <= target.radius then
      return true
    end

    return false
  end,

  ['model'] = function(target,pos,ent,endPos,modelHash) 
    if not ent then
      return false
    end

    if target.hash == modelHash then
      return true
    end

    return false
  end,

  ['localEnt'] = function(target,pos,ent,endPos)
    if not ent then
      return false
    end

    if #(pos - endPos) > target.radius then
      return false
    end

    if target.entId == ent then
      return true
    end

    return false
  end,

  ['networkEnt'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId)
    if not ent
    or not isNetworked 
    then
      return false
    end

    if #(pos - endPos) > target.radius then
      return false
    end

    if target.netId == netId then
      return true
    end

    return false
  end,

  ['polyZone'] = function(target)
    return target.isInside
  end,

  ['localEntBone'] = function(target,pos,ent,endPos)
    if not ent then
      return false
    end

    if #(pos - endPos) > target.radius then
      return false
    end

    if target.entId ~= ent then
      return false
    end

    if #(GetWorldPositionOfEntityBone(ent,target.bone) - pos) <= target.radius then
      return true
    end

    return false
  end,

  ['netEntBone'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId)
    if not ent then
      return false
    end

    if #(pos - endPos) > target.radius then
      return false
    end

    if target.netId ~= netId then
      return false
    end

    if #(GetWorldPositionOfEntityBone(ent,target.bone) - pos) <= target.radius then
      return true
    end

    return false
  end,

  ['modelBone'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId)
    if not ent then
      return false
    end

    if #(pos - endPos) > target.radius then
      return false
    end

    if target.hash ~= modelHash then
      return false
    end

    local boneIndex = GetEntityBoneIndexByName(ent,target.bone)
    local bonePos = GetWorldPositionOfEntityBone(ent,boneIndex)

    if #(pos - bonePos) <= target.radius then
      return true
    end

    return false
  end,
}

local function onSelect(target,option,...)
  if option.onSelect then
    return pcall(selectMethods[type(option.onSelect)],option,target,option,...)
  end

  return pcall(selectMethods[type(target.onSelect)],target,target,option,...)
end

local function shouldTargetRender(target,...)
  local res,ret,err = pcall(typeChecks[target.type],target,...)
  return ret
end

local function sendUiConfig()
  cfgSent = true

  SendNUIMessage({
    type = 'config',
    colors = Config.colors
  })
end

local function openUi()
  playerPed = PlayerPedId()
  isOpen = true
  activeTargets = {}

  if not cfgSent then
    sendUiConfig()
  end

  SendNUIMessage({
    type = 'open'
  })
end

local function closeUi()
  isOpen = false

  SendNUIMessage({
    type = 'close'
  })

  SetNuiFocus(false,false)
end

local function updateUi(targets)
  SendNUIMessage({
    type = 'setTargets',
    targets = targets
  })
end

local function isEntityValid(ent)
  if not ent or ent == -1 then
    return false
  end

  return DoesEntityExist(ent)
end

local function checkActiveTargets()
  local pos = GetEntityCoords(playerPed)
  local hit,endCoords,entityHit = s2w.get(-1,playerPed,0)
  local entityModel,netId,isNetworked = false,false,false

  if isEntityValid(entityHit) and GetEntityType(entityHit) ~= 0 then
    entityModel = GetEntityModel(entityHit)%0x100000000
    isNetworked = NetworkGetEntityIsNetworked(entityHit)

    if isNetworked then
      netId = NetworkGetNetworkIdFromEntity(entityHit)
    end
  end

  local newTargets = {}
  local didChange = false

  for _,target in ipairs(targets) do
    if shouldTargetRender(target,pos,entityHit,endCoords,entityModel,netId,isNetworked) then
      table.insert(newTargets,target)

      if not activeTargets[target.id] then
        activeTargets[target.id] = true
        didChange = true
        break
      end
    else
      if activeTargets[target.id] then
        activeTargets[target.id] = nil
        didChange = true
        break
      end
    end
  end

  if didChange then
    updateUi(newTargets)
  end
end

local gameName = GetGameName()
local uiFocus

local function targetUi()
  Wait(0)

  SetCursorLocation(0.5,0.5)
  SetNuiFocus(true,true)
  uiFocus = true
end

Citizen.CreateThread(function()
  local control        = gameName == 'redm' and 0x580C4473 or 37--Controls.Get("HudSpecial")
  local revealControl  = gameName == 'redm' and 0x07CE1E61 or 24--Controls.Get("RevealHud")
  local disableControl = gameName == 'redm' and 0x0F39B3D4 or 37--Controls.Get("SelectRadarMode")

  while true do
    Wait(0)

    DisableControlAction(0,control)
    DisableControlAction(0,revealControl)
    DisableControlAction(0,disableControl)

    if not uiFocus then
      if isOpen then
        DisablePlayerFiring(PlayerPedId(), true)
        checkActiveTargets()

        if IsDisabledControlJustReleased(0,control)
        or IsControlJustReleased(0,control) 
        then
          closeUi()
        end

        if IsDisabledControlJustReleased(0,revealControl)
        or IsControlJustReleased(0,revealControl)  
        then
          targetUi()
        end
      else
        if IsDisabledControlJustPressed(0,control)
        or IsControlJustPressed(0,control) 
        then
          openUi()
        end
      end
    end
  end
end)

RegisterNUICallback('closed',function()
  uiFocus = false
  isOpen  = false
  SetNuiFocus(false,false)
end)

RegisterNUICallback('select',function(data)
  data.id     = data.id
  data.index  = tonumber(data.index)+1
  
  local isActive = activeTargets[data.id]

  if not isActive then
    return
  end

  local target = targets[idIndexMap[data.id]]

  if not target then
    return
  end

  local option = target.items[data.index]

  if not option then
    return
  end
  
  uiFocus = false
  isOpen  = false
  SetNuiFocus(false,false)

  onSelect(target,option)
end)

local function addTarget(target)
  local targetIndex = #targets + 1

  targets[targetIndex] = target
  idIndexMap[target.id] = targetIndex

  return targetIndex
end

local function removeTarget(id)
  local index = idIndexMap[id]

  if not index then
    return
  end

  idIndexMap[id] = nil
  targets[index] = nil
end

local function evalArgs(argOrder,idOrOpts,...)
  if type(idOrOpts) == 'table' then
    local res = {}

    for _,arg in ipairs(argOrder) do
      table.insert(res,idOrOpts[arg])
    end

    return table.unpack(res)
  end

  return idOrOpts,...
end

local function addModel(...)
  local id,title,icon,model,radius,onSelect,items,vars = evalArgs({'id','title','icon','model','radius','onSelect','items','vars'},...)
  local hash = (type(model) == 'number' and model or GetHashKey(model))%0x100000000

  addTarget({
    id        = id,
    type      = 'model',
    title     = title,
    model     = model,
    hash      = hash,
    radius    = radius and radius or Config.DefaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = GetInvokingResource()
  })
end

local function addLocalEntBone(...)
  local id,title,icon,entId,bone,radius,onSelect,items,vars = evalArgs({'id','title','icon','entId','bone','radius','onSelect','items','vars'},...)
  local modelHash = (type(model) == 'number' and model or GetHashKey(model)) %0x100000000

  addTarget({
    id        = id,
    type      = 'localEntBone',
    title     = title,
    entId     = entId,
    hash      = modelHash,
    bone      = bone,
    radius    = radius and radius or Config.DefaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = GetInvokingResource()
  })
end

local function addNetEntBone(...)
  local id,title,icon,netId,bone,radius,onSelect,items,vars = evalArgs({'id','title','icon','netId','bone','radius','onSelect','items','vars'},...)
  local modelHash = (type(model) == 'number' and model or GetHashKey(model)) %0x100000000

  addTarget({
    id        = id,
    type      = 'netEntBone',
    title     = title,
    netId     = netId,
    hash      = modelHash,
    bone      = bone,
    radius    = radius and radius or Config.DefaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = GetInvokingResource()
  })
end

local function addModelBone(...)
  local id,title,icon,model,bone,radius,onSelect,items,vars = evalArgs({'id','title','icon','model','bone','radius','onSelect','items','vars'},...)
  local modelHash = (type(model) == 'number' and model or GetHashKey(model)) %0x100000000

  addTarget({
    id        = id,
    type      = 'modelBone',
    title     = title,
    model     = model,
    hash      = modelHash,
    bone      = bone,
    radius    = radius and radius or Config.DefaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = GetInvokingResource()
  })
end

local apiFunctions = {
  ['addPoint'] = function(...)
    local id,title,icon,point,radius,onSelect,items,vars = evalArgs({'id','title','icon','point','radius','onSelect','items','vars'},...)

    addTarget({
      id        = id,
      type      = 'point',
      title     = title,
      point     = point,
      radius    = radius and radius or Config.DefaultRadius,
      onSelect  = onSelect,
      items     = items,
      vars      = vars,
      resource  = GetInvokingResource()
    })
  end,

  ['addModel'] = addModel,

  ['addModels'] = function(...)
    local id,title,icon,models,radius,onSelect,items,vars = evalArgs({'id','title','icon','models','radius','onSelect','items','vars'},...)

    for i=1,#models do
      addModel(id .. ":" .. i,title,icon,models[i],radius and radius or Config.DefaultRadius,onSelect,items,vars)
    end
  end,

  ['addNetEnt'] = function(...)
    local id,title,icon,netId,radius,onSelect,items,vars = evalArgs({'id','title','icon','netId','radius','onSelect','items','vars'},...)

    addTarget({
      id        = id,
      type      = 'networkEnt',
      title     = title,
      netId     = netId,
      radius    = radius and radius or Config.DefaultRadius,
      onSelect  = onSelect,
      items     = items,
      vars      = vars,
      resource  = GetInvokingResource()
    })
  end,

  ['addLocalEnt'] = function(...)
    local id,title,icon,entId,radius,onSelect,items,vars = evalArgs({'idOrOpts','title','icon','entId','radius','onSelect','items','vars'},...)

    addTarget({
      id        = id,
      type      = 'localEnt',
      title     = title,
      entId     = entId,
      radius    = radius and radius or Config.DefaultRadius,
      onSelect  = onSelect,
      items     = items,
      vars      = vars,
      resource  = GetInvokingResource()
    })
  end,

  ['addInternalPoly'] = function(...)
    local id,title,icon,points,options,onSelect,items,vars = evalArgs({'id','title','icon','points','options','onSelect','items','vars'},...)

    local target = {
      id        = id,
      type      = 'polyZone',
      title     = title,
      radius    = radius and radius or Config.DefaultRadius,
      onSelect  = onSelect,
      items     = items,
      vars      = vars,
      resource  = GetInvokingResource()
    }

    local polyZone = PolyZone:Create(points,options)

    polyZone:onPointInOut(PolyZone.getPlayerPosition,function(isPointInside,point)
      target.isInside = isPointInside
    end,100)

    addTarget(target)
  end,

  ['addExternalPoly'] = function(...)
    local id,title,icon,onSelect,items,vars = evalArgs({'id','title','icon','onSelect','items','vars'},...)

    local target = {
      id        = id,
      type      = 'polyZone',
      title     = title,
      radius    = radius and radius or Config.DefaultRadius,
      onSelect  = onSelect,
      items     = items,
      vars      = vars,
      resource  = GetInvokingResource()
    }

    addTarget(target)

    return function(isInside)    
      target.isInside = isInside
    end
  end,

  ['addInternalBoxZone'] = function(...)
    local id,title,icon,center,length,width,options,onSelect,items,vars = evalArgs({'id','title','icon','center','length','width','options','onSelect','items','vars'},...)

    local target = {
      id        = id,
      type      = 'polyZone',
      title     = title,
      radius    = radius and radius or Config.DefaultRadius,
      onSelect  = onSelect,
      items     = items,
      vars      = vars,
      resource  = GetInvokingResource()
    }

    local boxZone = BoxZone:Create(center,length,width,options)

    boxZone:onPointInOut(PolyZone.getPlayerPosition,function(isPointInside,point)
      target.isInside = isPointInside
    end,500)

    addTarget(target)
  end,

  ['addExternalBoxZone'] = function(...)
    local id,title,icon,onSelect,items,vars = evalArgs({'id','title','icon','onSelect','items','vars'},...)

    local target = {
      id        = id,
      type      = 'polyZone',
      title     = title,
      radius    = radius and radius or Config.DefaultRadius,
      onSelect  = onSelect,
      items     = items,
      vars      = vars,
      resource  = GetInvokingResource()
    }

    addTarget(target)

    return function(isInside)    
      target.isInside = isInside
    end
  end,

  ['addNetEntBone'] = addNetEntBone,

  ['addNetEntBones'] = function(...)
    local id,title,icon,netId,bones,radius,onSelect,items,vars = evalArgs({'id','title','icon','netId','bones','radius','onSelect','items','vars'},...)

    for i=1,#bones do
      addNetEntBone(id .. ":" .. i,title,icon,netId,bones[i],radius and radius or Config.DefaultRadius,onSelect,items,vars)
    end
  end,

  ['addLocalEntBone'] = addLocalEntBone,

  ['addLocalEntBones'] = function(...)
    local id,title,icon,entId,bones,radius,onSelect,items,vars = evalArgs({'id','title','icon','entId','bones','radius','onSelect','items','vars'},...)

    for i=1,#bones do
      addLocalEntBone(id .. ":" .. i,title,icon,entId,bones[i],radius and radius or Config.DefaultRadius,onSelect,items,vars)
    end
  end,

  ['addModelBone'] = addModelBone,

  ['addModelBones'] = function(...)
    local id,title,icon,model,bones,radius,onSelect,items,vars = evalArgs({'id','title','icon','model','bones','radius','onSelect','items','vars'},...)

    for i=1,#bones do
      addModelBone(id .. ":" .. i,title,icon,model,bones[i],radius and radius or Config.DefaultRadius,onSelect,items,vars)
    end
  end,

  ['remove'] = removeTarget
}

local exportNames = {}

for exportName,fn in pairs(apiFunctions) do
  exports(exportName,fn)
  exportNames[#exportNames+1] = exportName
end

exports('getExportNames',function()
  return exportNames
end)
