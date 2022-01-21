local targets = {}
local activeTargets = {}
local idIndexMap = {}
local isOpen
local cfgSent

local selectMethods = {
  ['function'] = function(t,...)
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

    if #(GetWorldPositionOfEntityBone(ent,target.bone) - pos) <= target.radius then
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
  return pcall(typeChecks[target.type],target,...)
end

local function sendUiConfig()
  cfgSent = true

  SendNUIMessage({
    type = 'config',
    colors = Config.colors
  })
end

local function openUi()
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
  local pos = GetEntityCoords(PlayerPedId())
  local hit,endCoords,entityHit = s2w.get()
  local entityModel,netId,isNetworked = false,false,false

  if isEntityValid(entityHit) then
    entityHit   = false
    entityModel = GetEntityModel(entityHit)%0x100000000
    isNetworked = NetworkGetEntityIsNetworked(entityHit)

    if isNetworked then
      netId = NetworkGetNetworkIdFromEntity(entityHit)
    end
  end

  local newTargets = {}
  local didChange = false

  for _,target in ipairs(targets) do
    if shouldTargetRender(target,pos,entHit,endCoords,entityModel,netId,isNetworked) then
      if not activeTargets[target.id] then
        activeTargets[target.id] = true
        didChange = true
        break
      end

      table.insert(newTargets,target)
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

Citizen.CreateThread(function()
  local control = Controls.Get("HudSpecial")

  while not PlayerData.Get('character') do
    Wait(100)
  end

  while true do
    Wait(0)

    Controls.DisableKey(control)
    Controls.DisableKey(0xCF8A4ECA)
    Controls.DisableKey(0x0F39B3D4)

    if isOpen then
      if Controls.GetDisabledKeyReleased(control)
      or Controls.GetKeyReleased(control) 
      then
        closeUi()
      end

      checkActiveTargets()
    else
      if Controls.GetDisabledKeyPressed(control)
      or Controls.GetKeyPressed(control) 
      then
        openUi()
      end
    end
  end
end)

RegisterNUICallback('closed',function()
  SetNuiFocus(false,false)
end)

RegisterNUICallback('select',function(data)
  local target = activeTargets[data.id]

  if not target then
    return
  end

  local option = target.items[data.index]

  if not option then
    return
  end

  onSelect(target,option)
end)

local function addTarget(target)
  local targetIndex = #targets + 1

  targets[targetIndex] = target
  idIndexMap[target.id] = targetIndex

  return targetIndex
end

local function removeTarget(id)
  local index = idIndexMap(id)

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
  local hash = type(model) == 'number' and model or GetHashKey(model)%0x100000000

  addTarget({
    id        = id,
    type      = 'model',
    title     = title,
    model     = model,
    hash      = hash,
    radius    = radius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = GetInvokingResource()
  })
end

local function addLocalEntBone(...)
  local id,title,icon,entId,bone,radius,onSelect,items,vars = evalArgs({'id','title','icon','entId','bone','radius','onSelect','items','vars'},...)

  addTarget({
    id        = id,
    type      = 'localEntBone',
    title     = title,
    entId     = entId,
    bone      = bone,
    radius    = radius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = GetInvokingResource()
  })
end

local function addNetEntBone(...)
  local id,title,icon,netId,bone,radius,onSelect,items,vars = evalArgs({'id','title','icon','netId','bone','radius','onSelect','items','vars'},...)

  addTarget({
    id        = id,
    type      = 'netEntBone',
    title     = title,
    netId     = netId,
    bone      = bone,
    radius    = radius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = GetInvokingResource()
  })
end

local function addModelBone(...)
  local id,title,icon,model,bone,radius,onSelect,items,vars = evalArgs({'id','title','icon','model','bone','radius','onSelect','items','vars'},...)
  local hash = type(bone) == 'number' and bone or GetHashKey(bone)%0x100000000

  addTarget({
    id        = id,
    type      = 'modelBone',
    title     = title,
    model     = model,
    hash      = hash,
    bone      = bone,
    radius    = radius,
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
      radius    = radius,
      onSelect  = onSelect,
      items     = items,
      vars      = vars,
      resource  = GetInvokingResource()
    })
  end,

  ['addModel'] = addModel,

  ['addModels'] = function(...)
    local id,title,icon,models,radius,onSelect,items,vars = evalArgs({'id','title','icon','models','radius','onSelect','items','vars'},...)

    for i=1,#,models do
      addModel(id .. ":" .. i,title,icon,models[i],radius,onSelect,items,vars)
    end
  end,

  ['addNetEnt'] = function(...)
    local id,title,icon,netId,radius,onSelect,items,vars = evalArgs({'id','title','icon','netId','radius','onSelect','items','vars'},...)

    addTarget({
      id        = id,
      type      = 'networkEnt',
      title     = title,
      netId     = netId,
      radius    = radius,
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
      radius    = radius,
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

    for i=1,#,bones do
      addNetEntBone(id .. ":" .. i,title,icon,netId,bones[i],radius,onSelect,items,vars)
    end
  end,

  ['addLocalEntBone'] = addLocalEntBone,

  ['addLocalEntBones'] = function(...)
    local id,title,icon,entId,bones,radius,onSelect,items,vars = evalArgs({'id','title','icon','entId','bones','radius','onSelect','items','vars'},...)

    for i=1,#,bones do
      addLocalEntBone(id .. ":" .. i,title,icon,entId,bones[i],radius,onSelect,items,vars)
    end
  end,

  ['addModelBone'] = addModelBone,

  ['addModelBones'] = function(...)
    local id,title,icon,model,bones,radius,onSelect,items,vars = evalArgs({'id','title','icon','model','bones','radius','onSelect','items','vars'},...)

    for i=1,#,bones do
      addModelBone(id .. ":" .. i,title,icon,model,bones[i],radius,onSelect,items,vars)
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

-- local control1 = Controls.Get("MeleeBlock")
-- local control2 = Controls.Get("MeleeAttack")
-- local pg = Prompts.NewGroup('Barrel')

-- local pos = vector3(-296.58,786.14,118.33)
-- local isPressing = false

-- Prompts.NewPrompt(
--   'Drink',
--   control1,
--   true,
--   pg,
--   function()
--   end
-- )

-- local start = GetGameTimer()
-- local isActive
-- local isShown

-- while true do
--   local dist = #(GetEntityCoords(PlayerPedId()) - pos)
--   if dist <= 5.0 then
--     if not isActive then
--       isActive = true
--       TaskLookAtCoord(PlayerPedId(),pos.x,pos.y,pos.z,-1,true,true)
--       SetGameplayCoordHint(pos.x,pos.y,pos.z, -1, 1000, 1000, 0)
--     end

--     if dist <= 2.0 then
--       if not isShown then
--         isShown = true
--         pg:show()
--       end
--     else
--       if isShown then
--         isShown = false
--         pg:hide()
--       end
--     end
--   else
--     if isActive then
--       isShown = false
--       isActive = false
--       StopGameplayHint(true)
--       TaskClearLookAt(PlayerPedId())
--       pg:hide()
--     end
--   end

--   Wait(0)
-- end

-- TaskClearLookAt(PlayerPedId())

-- pg:hide()

-- RegisterCommand('toggleui',function()
--   if not isOpen then
--     openUi()
--   else
--     closeUi()
--   end
-- end)  