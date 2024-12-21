-- targets and id mapping
local targets = {}
local activeTargets = {}

-- ui
local isOpen
local isDisable
local cfgSent
local uiFocus

-- locals
local endCoords = vec3(0,0,0)
local playerPed = PlayerPedId()

-- exports
local exportNames = {}

local function getEndCoords()
  return endCoords
end

local function getExportNames()
  return exportNames
end

local selectMethods = {
  ['function'] = function(t,...)
    local result
    local arguments = {...}
    pcall(function()
      result = t.onSelect(table.unpack(arguments))
    end)
    return result
  end,

  ['table'] = function(t,...)
    local result
    local arguments = {...}
    pcall(function()
      result = t.onSelect(table.unpack(arguments))
    end)
    return result
  end,

  ['string'] = function(t,...)
    return TriggerEvent(t.onSelect,...)
  end
}

local typeChecks = {
  ['point'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType) 
    if targetDist > target.radius then
      return false
    end

    if #(endPos - target.point) > target.radius then
      return false
    end

    if target.canInteract then
      local canInteract = false
      pcall(function()
        canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
      end)
      return canInteract
    else
      return true
    end
  end,

  ['model'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType) 
    if not ent then
      return false
    end

    if target.hash ~= modelHash then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if target.canInteract then
      local canInteract = false
      pcall(function()
        canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
      end)
      return canInteract
    else
      return true
    end
  end,

  ['localEnt'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if target.entId ~= ent then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if target.canInteract then
      local canInteract = false
      pcall(function()
        canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
      end)
      return canInteract
    else
      return true
    end
  end,

  ['networkEnt'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent
    or not isNetworked 
    then
      return false
    end

    if target.netId ~= netId then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if target.canInteract then
      local canInteract = false
      pcall(function()
        canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
      end)
      return canInteract
    else
      return true
    end
  end,

  ['polyZone'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if target.radius and targetDist > target.radius then
      return false
    end

    if not (type(target.isInside) ~= "function" and target.isInside or target.isInside()) then
      return false
    end

    if target.canInteract then
      local canInteract = false
      pcall(function()
        canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
      end)
      return canInteract
    else
      return true
    end
  end,

  ['localEntBone'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if target.entId ~= ent then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if #(GetWorldPositionOfEntityBone(ent,target.bone) - pos) > target.radius then
      return false
    end

    if target.canInteract then
      local canInteract = false
      pcall(function()
        canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
      end)
      return canInteract
    else
      return true
    end
  end,

  ['netEntBone'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if target.netId ~= netId then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if #(GetWorldPositionOfEntityBone(ent,target.bone) - pos) > target.radius then
      return false
    end

    if target.canInteract then
      local canInteract = false
      pcall(function()
        canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
      end)
      return canInteract
    else
      return true
    end
  end,

  ['modelBone'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if target.hash ~= modelHash then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    local boneIndex = GetEntityBoneIndexByName(ent,target.bone)
    local bonePos = GetWorldPositionOfEntityBone(ent,boneIndex)

    if #(pos - bonePos) > target.radius then
      return false
    end

    if target.canInteract then
      local canInteract = false
      pcall(function()
        canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
      end)
      return canInteract
    else
      return true
    end
  end,

  ['bone'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if entityType == 2 then
      local boneIndex = GetEntityBoneIndexByName(ent,target.bone)
      local bonePos = GetWorldPositionOfEntityBone(ent,boneIndex)

      if #(pos - bonePos) > target.radius then
        return false
      end

      if target.canInteract then
        local canInteract = false
        pcall(function()
          canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        end)
        return canInteract
      else
        return true
      end
    end
  end,

  ['player'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if not entityType then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if not IsPedAPlayer(ent) then
      return false
    end

    if entityType == 1 then
      if target.canInteract then
        local canInteract = false
        pcall(function()
          canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        end)
        return canInteract
      else
        return true
      end
    end
  end,

  ['ped'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if not entityType then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if IsPedAPlayer(ent) then
      return false
    end

    if entityType == 1 then
      if target.canInteract then
        local canInteract = false
        pcall(function()
          canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        end)
        return canInteract
      else
        return true
      end
    end
  end,

  ['vehicle'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if not entityType then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if entityType == 2 then
      if target.canInteract then
        local canInteract = false
        pcall(function()
          canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        end)
        return canInteract
      else
        return true
      end
    end
  end,

  ['object'] = function(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
    if not ent then
      return false
    end

    if not entityType then
      return false
    end

    if targetDist > target.radius then
      return false
    end

    if entityType == 3 then
      if target.canInteract then
        local canInteract = false
        pcall(function()
          canInteract = target.canInteract(target,pos,ent,endPos,modelHash,isNetworked,netId,targetDist,entityType)
        end)
        return canInteract
      else
        return true
      end
    end
  end
}

local function onSelect(target,option,...)
  if option.onSelect then
    return selectMethods[type(option.onSelect)](option,target,option,...)
  end

  return selectMethods[type(target.onSelect)](target,target,option,...)
end

local function shouldTargetRender(target,...)
  return typeChecks[target.type](target,...)
end

local function sendUiConfig()
  cfgSent = true

  SendNUIMessage({
    type = 'config',
    colors = Config.colors
  })
end

local function cleanse(t)
  local res = {}

  for k,v in pairs(t) do
    local t = type(v)

    if t == 'table' then
      res[k] = cleanse(v)
    elseif t == 'function' then
      res[k] = false
    else
      res[k] = v
    end
  end

  return res
end

local function updateUi(targets)
  SendNUIMessage({
    type = 'setTargets',
    targets = cleanse(targets)
  })
end

local function isEntityValid(ent)
  if not ent or ent == -1 then
    return false
  end

  return DoesEntityExist(ent)
end

local function deepcopy(orig, blacklistedKeys, blackListedTypes)
  local orig_type = type(orig)
  local copy
  if not blackListedTypes or not blackListedTypes[orig_type] then
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
          if not blacklistedKeys or not blacklistedKeys[tostring(orig_key)] then
            copy[deepcopy(orig_key, blacklistedKeys, blackListedTypes)] = deepcopy(orig_value, blacklistedKeys, blackListedTypes)
          end
        end
        setmetatable(copy, deepcopy(getmetatable(orig), blacklistedKeys, blackListedTypes))
    else -- number, string, boolean, etc
        copy = orig
    end
  end
  return copy
end

local function table_matches(t1, t2)
	local type1, type2 = type(t1), type(t2)

	if type1 ~= type2 then return false end
	if type1 ~= 'table' and type2 ~= 'table' then return t1 == t2 end

	for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not table_matches(v1,v2) then return false end
	end

	for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not table_matches(v1,v2) then return false end
	end

	return true
end

local didChange = false
local function checkActiveTargets()
  local pos = GetEntityCoords(playerPed)
  local hit,endPos,entityHit = s2w.get(-1,playerPed,0)
  local entityModel,netId,isNetworked,targetDist,entityType = false,false,false,false,false

  if isEntityValid(entityHit) and GetEntityType(entityHit) ~= 0 then
    entityModel = GetEntityModel(entityHit)%0x100000000
    isNetworked = NetworkGetEntityIsNetworked(entityHit)
    entityType  = GetEntityType(entityHit)

    if isNetworked then
      netId = NetworkGetNetworkIdFromEntity(entityHit)
    end
  end

  endCoords   = endPos

  local newTargets = {}

  targetDist = #(endPos - pos)

  for _,target in ipairs(targets) do
    if shouldTargetRender(target,pos,entityHit,endCoords,entityModel,isNetworked,netId,targetDist,entityType) then
      local newTarget = deepcopy(target, {
        ["zoneHandel"] = true,
        ["onInteract"] = true,
        ["canInteract"] = true,
      }, {
        ["function"] = true,
      })
      local itemStates = {}
      for i = #newTarget.items,1,-1 do
        local v = newTarget.items[i]
        local canInteractFunc = target.items[i].canInteract
        newTarget.items[i].ui_temp_index = i - 1
        if v and canInteractFunc then
          local canInteract = false
          pcall(function()
            canInteract = canInteractFunc(target,v,pos,entityHit,endCoords,entityModel,isNetworked,netId,targetDist,entityType)
          end)
          if not canInteract then
            table.remove(newTarget.items,i)
            itemStates[i] = false
          else
            itemStates[i] = true
          end
          v.canInteract = nil
        end
      end

      if #newTarget.items > 0 then
        table.insert(newTargets,newTarget)
        if not activeTargets[target.id] then
          activeTargets[target.id] = {
            target = target,
            pos = pos,
            entityHit = entityHit,
            endPos = endPos,
            entityModel = entityModel,
            isNetworked = isNetworked,
            netId = netId,
            targetDist = targetDist,
            entityType = entityType,
            itemStates = itemStates,
          }
          didChange = true
        elseif not table_matches(activeTargets[target.id].itemStates,itemStates) then
          activeTargets[target.id].itemStates = itemStates
          didChange = true
        end
      elseif activeTargets[target.id] then
        activeTargets[target.id] = nil
        didChange = true
      end
    else
      if activeTargets[target.id] then
        activeTargets[target.id] = nil
        didChange = true
      end
    end
  end

  if didChange then
    updateUi(newTargets)
    didChange = false
  end
end

local function targetUi()
  Wait(0)

  SetCursorLocation(0.5,0.5)
  SetNuiFocus(true,true)
  uiFocus = true
end

local checkActiveThreadBool = false
local checkActiveThread = function()
  if checkActiveThreadBool then
    return
  end
  checkActiveThreadBool = true
  CreateThread(function()
    while isOpen do
      Wait(100)
      checkActiveTargets()
    end
    checkActiveThreadBool = false
  end)
end

local function openUi()
  isOpen = true
  checkActiveThread()
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

lib.onCache('ped', function(value)
  playerPed = value
end)

Citizen.CreateThread(function()
  local gameName      = GetGameName()
  local control       = gameName == 'redm' and 0x580C4473 or 19
  local revealControl = gameName == 'redm' and 0x07CE1E61 or 24
  if gameName == 'redm' then
    lib.disableControls:Add({control,revealControl,0x0F39B3D4})
  else
    lib.disableControls:Add({control})
  end

  while true do
    Wait(5)

    lib.disableControls()

    if isOpen then
      DisablePlayerFiring(playerPed, true)

      if not isDisable
      and (IsDisabledControlJustReleased(0,revealControl)
      or IsControlJustReleased(0,revealControl))
      then
        targetUi()
      end

      if not uiFocus then
        if isDisable
        or IsDisabledControlJustReleased(0,control)
        then
          closeUi()
        end
      end
    elseif not isDisable then
      if IsDisabledControlJustPressed(0,control)
      then
        openUi()
      end
    end
  end
end)

RegisterNUICallback('closed',function()
  uiFocus = false
  isOpen = false
  SetNuiFocus(false,false)
end)

RegisterNUICallback('select',function(data)
  data.id     = data.id
  data.index  = tonumber(data.index)+1

  local targetData = activeTargets[data.id]

  if not targetData then
    return
  end

  local entHit = targetData.entityHit or false
  local target = targetData.target

  if not target then
    return
  end

  local option = target.items[data.index]

  if not option then
    return
  end

  uiFocus = false
  isOpen = false
  SetNuiFocus(false,false)

  onSelect(target,option,entHit,targetData)
end)

local function addTarget(target)
  table.insert(targets,target)
end

mTarget = {}

function mTarget.disableTargeting(state)
  isDisable = state
  if isOpen then
    closeUi()
  end
end

function mTarget.removeTarget(...)
  for i=1,select("#",...),1 do
    local id = select(i,...)

    for i=#targets,1,-1 do
      if targets[i].id == id then
        if targets[i].zoneHandel then
          if targets[i].zoneCreatorCore == "ox_lib" and targets[i].zoneHandel.remove then
            targets[i].zoneHandel:remove()
          elseif targets[i].zoneHandel.destroy then
            targets[i].zoneHandel:destroy()
          end
        end
        table.remove(targets,i)
      end
    end

    if activeTargets[id] then
      activeTargets[id] = nil
      didChange = true
    end
  end
end

function mTarget.removeItemFromTarget(id,...)
  local tableIndexes = {...}
  local fullyRemoved = false
  local newItems = {}
  table.sort(tableIndexes, function(a,b) return a > b end)
  for i=#targets,1,-1 do
    if targets[i].id == id then
      for _,index in ipairs(tableIndexes) do
        table.remove(targets[i].items,index)
      end
      if #targets[i].items == 0 then
        if targets[i].zoneHandel then
          if targets[i].zoneCreatorCore == "ox_lib" and targets[i].zoneHandel.remove then
            targets[i].zoneHandel:remove()
          elseif targets[i].zoneHandel.destroy then
            targets[i].zoneHandel:destroy()
          end
        end
        table.remove(targets,i)
        fullyRemoved = true
      end
      if not fullyRemoved then
        newItems = targets[i].items
      end
      if activeTargets[id] then
        CreateThread(checkActiveTargets)
      end
    end
  end
  return fullyRemoved,newItems
end

function mTarget.getTargetInfo(...)
  local results = {}
  for i=1,select("#",...),1 do
    local id = select(i,...)
    for i=#targets,1,-1 do
      if targets[i].id == id then
        table.insert(results,targets[i])
      end
    end
  end
  return results
end

function mTarget.getTargetByType(type)
  local results = {}
  for i=1,#targets,1 do
    if targets[i].type == type then
      table.insert(results,targets[i])
    end
  end
  return results
end

function mTarget.getTargets()
  return targets
end

function mTarget.getActiveTargets()
  return activeTargets
end

function mTarget.updateTargetInfo(id,info)
  for i=1,#targets,1 do
    if targets[i].id == id then
      for k,v in pairs(info) do
        targets[i][k] = v
      end
    end
  end
end

function mTarget.addModel(id,title,icon,model,radius,onSelect,items,vars,res,canInteract)
  local hash = (type(model) == 'number' and model or GetHashKey(model))%0x100000000

  addTarget({
    id        = id,
    type      = 'model',
    title     = title,
    icon      = icon,
    model     = model,
    hash      = hash,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addModelBone(id,title,icon,model,bone,radius,onSelect,items,vars,res,canInteract)
  local modelHash = (type(model) == 'number' and model or GetHashKey(model)) %0x100000000

  addTarget({
    id        = id,
    type      = 'modelBone',
    title     = title,
    icon      = icon,
    model     = model,
    hash      = modelHash,
    bone      = bone,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addBone(id,title,icon,bone,radius,onSelect,items,vars,res,canInteract)
  addTarget({
    id        = id,
    type      = 'bone',
    title     = title,
    icon      = icon,
    bone      = bone,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addBones(id,title,icon,bones,radius,onSelect,items,vars,res,canInteract)
  local targetIds = {}

  for i=1,#bones do
    local targetId = id .. ":" .. i

    mTarget.addBone(targetId,title,icon,bones[i],radius or Config.defaultRadius,onSelect,items,vars,res,canInteract)

    table.insert(targetIds,targetId)
  end

  return table.unpack(targetIds)
end

function mTarget.addModelBones(id,title,icon,model,bones,radius,onSelect,items,vars,res,canInteract)
  if type(model) ~= 'table' then model = {model} end
  local targetIds = {}

  for i=1,#bones do
    local targetId = id .. ":" .. i

    mTarget.addModelBone(targetId,title,icon,model,bones[i],radius or Config.defaultRadius,onSelect,items,vars,res,canInteract)

    table.insert(targetIds,targetId)
  end

  return table.unpack(targetIds)
end

function mTarget.addPoint(id,title,icon,point,radius,onSelect,items,vars,res,canInteract)
  addTarget({
    id        = id,
    type      = 'point',
    title     = title,
    icon      = icon,
    point     = point,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addModels(id,title,icon,models,radius,onSelect,items,vars,res,canInteract)
  local targetIds = {}

  for i=1,#models do
    local targetId = id .. ":" .. i

    mTarget.addModel(targetId,title,icon,models[i],radius or Config.defaultRadius,onSelect,items,vars,res,canInteract)

    table.insert(targetIds,targetId)
  end

  return table.unpack(targetIds)
end

function mTarget.addNetEnt(id,title,icon,netId,radius,onSelect,items,vars,res,canInteract)
  addTarget({
    id        = id,
    type      = 'networkEnt',
    title     = title,
    icon      = icon,
    netId     = netId,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addLocalEnt(id,title,icon,entId,radius,onSelect,items,vars,res,canInteract)
  addTarget({
    id        = id,
    type      = 'localEnt',
    title     = title,
    icon      = icon,
    entId     = entId,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addInternalPoly(id,title,icon,points,options,radius,onSelect,items,vars,res,canInteract,zoneCreatorCore)
  local target = {
    id        = id,
    type      = 'polyZone',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
    zoneCreatorCore = zoneCreatorCore
  }

  local polyZone
  local isDebug = options and (options.debug or options.debugPoly or options.drawSprite) or false
  if zoneCreatorCore == 'ox_lib' then
    local thickness = 99999.0
    if options and options.minZ and options.maxZ then
      thickness = math.abs(options.maxZ - options.minZ)
    end
    local newPoints = {}
    for i=1,#points do
      table.insert(newPoints,vector3(points[i].x,points[i].y,(options.maxZ and options.maxZ - (thickness / 2)) or 0.0))
    end
    polyZone = lib.zones.poly({
      points = newPoints,
      thickness = thickness,
      debug = isDebug,
      options = options,
    })
    target.zoneHandel = polyZone
    target.isInside = function()
      return polyZone:contains(getEndCoords())
    end
  else
    polyZone = PolyZone:Create(points,options)
    target.zoneHandel = polyZone
    target.isInside = function()
      return polyZone:isPointInside(getEndCoords())
    end
  end

  addTarget(target)
  return polyZone
end

function mTarget.addExternalPoly(id,title,icon,radius,onSelect,items,vars,res,canInteract)
  local target = {
    id        = id,
    type      = 'polyZone',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  }

  addTarget(target)

  return function(isInside)
    target.isInside = isInside
  end
end

function mTarget.addInternalBoxZone(id,title,icon,center,length,width,options,radius,onSelect,items,vars,res,canInteract,zoneCreatorCore)
  local target = {
    id        = id,
    type      = 'polyZone',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
    zoneCreatorCore = zoneCreatorCore
  }

  local boxZone
  local isDebug = options and (options.debug or options.debugPoly or options.drawSprite) or false
  if zoneCreatorCore == 'ox_lib' then
    local height = 99999.0
    if options and options.minZ and options.maxZ then
      height = math.abs(options.maxZ - options.minZ)
    end
    boxZone = lib.zones.box({
      coords = center,
      size = vector3(length,width,height),
      rotation = options and options.heading or 0.0,
      debug = isDebug,
    })
    target.zoneHandel = boxZone
    target.isInside = function()
      return boxZone:contains(getEndCoords())
    end
  else
    boxZone = BoxZone:Create(center,length,width,options)
    target.zoneHandel = boxZone
    target.isInside = function()
      return boxZone:isPointInside(getEndCoords())
    end
  end


  addTarget(target)
  return boxZone
end

function mTarget.addExternalBoxZone(id,title,icon,radius,onSelect,items,vars,res,canInteract)
  local target = {
    id        = id,
    type      = 'polyZone',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    radius    = radius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  }

  addTarget(target)

  return function(isInside)
    target.isInside = isInside
  end
end

function mTarget.addInternalSphereZone(id,title,icon,center,sphereRadius,options,radius,onSelect,items,vars,res,canInteract,zoneCreatorCore)
  local target = {
    id        = id,
    type      = 'polyZone',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
    zoneCreatorCore = zoneCreatorCore
  }

  local isDebug = options and (options.debug or options.debugPoly or options.drawSprite) or false
  local circleZone
  if zoneCreatorCore == 'ox_lib' then
    circleZone = lib.zones.sphere({
      coords = center,
      radius  = sphereRadius,
      debug = isDebug,
    })
    target.zoneHandel = circleZone
    target.isInside = function()
      return circleZone:contains(getEndCoords())
    end
  else
    circleZone = CircleZone:Create(center,sphereRadius,options)
    target.zoneHandel = circleZone
    target.isInside = function()
      return circleZone:isPointInside(getEndCoords())
    end
  end


  addTarget(target)
  return circleZone
end

function mTarget.addExternalSphereone(id,title,icon,radius,onSelect,items,vars,res,canInteract)
  local target = {
    id        = id,
    type      = 'polyZone',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  }

  addTarget(target)

  return function(isInside)
    target.isInside = isInside
  end
end

function mTarget.addNetEntBone(id,title,icon,netId,bone,radius,onSelect,items,vars,res,canInteract)
  local modelHash = (type(model) == 'number' and model or GetHashKey(model)) %0x100000000

  addTarget({
    id        = id,
    type      = 'netEntBone',
    title     = title,
    icon      = icon,
    netId     = netId,
    hash      = modelHash,
    bone      = bone,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addNetEntBones(id,title,icon,netId,bones,radius,onSelect,items,vars,res,canInteract)
  local targetIds = {}

  for i=1,#bones do
    local targetId = id .. ":" .. i

    mTarget.addNetEntBone(targetId,title,icon,netId,bones[i],radius or Config.defaultRadius,onSelect,items,vars,res,canInteract)

    table.insert(targetIds,targetId)
  end

  return table.unpack(targetIds)
end

function mTarget.addLocalEntBone(id,title,icon,entId,bone,radius,onSelect,items,vars,res,canInteract)
  local modelHash = (type(model) == 'number' and model or GetHashKey(model)) %0x100000000

  addTarget({
    id        = id,
    type      = 'localEntBone',
    title     = title,
    icon      = icon,
    entId     = entId,
    hash      = modelHash,
    bone      = bone,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addLocalEntBones(id,title,icon,entId,bones,radius,onSelect,items,vars,res,canInteract)
  local targetIds = {}

  for i=1,#bones do
    local targetId = id .. ":" .. i

    mTarget.addLocalEntBone(targetId,title,icon,entId,bones[i],radius or Config.defaultRadius,onSelect,items,vars,res,canInteract)

    table.insert(targetIds,targetId)
  end

  return table.unpack(targetIds)
end

function mTarget.addPlayer(id,title,icon,radius,onSelect,items,vars,res,canInteract)
  addTarget({
    id        = id,
    type      = 'player',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addVehicle(id,title,icon,radius,onSelect,items,vars,res,canInteract)
  addTarget({
    id        = id,
    type      = 'vehicle',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addObject(id,title,icon,radius,onSelect,items,vars,res,canInteract)
  addTarget({
    id        = id,
    type      = 'object',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

function mTarget.addPed(id,title,icon,radius,onSelect,items,vars,res,canInteract)
  addTarget({
    id        = id,
    type      = 'ped',
    title     = title,
    icon      = icon,
    radius    = radius or Config.defaultRadius,
    onSelect  = onSelect,
    items     = items,
    vars      = vars,
    resource  = res or GetInvokingResource(),
    canInteract  = canInteract,
  })
end

for fnName,fn in pairs(mTarget) do
  exports(fnName,fn)
  exportNames[#exportNames+1] = fnName
end

exports('getEndCoords',getEndCoords)
exports('getExportNames',getExportNames)

AddEventHandler('onClientResourceStop',function(res)
  for i=#targets,1,-1 do
    if targets[i].resource == res then
      if targets[i].zoneHandel then
        if targets[i].zoneCreatorCore == "ox_lib" and targets[i].zoneHandel.remove then
          targets[i].zoneHandel:remove()
        elseif targets[i].zoneHandel.destroy then
          targets[i].zoneHandel:destroy()
        end
      end
      table.remove(targets,i)
    end
  end
end)
