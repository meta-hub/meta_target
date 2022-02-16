local rotationToDirection = function(rotation)
  local x = rotation.x * math.pi / 180.0
  local z = rotation.z * math.pi / 180.0
  local num = math.abs(math.cos(x))
  return vector3((-math.sin(z) * num), (math.cos(z) * num), math.sin(x))
end
 
local world3DToScreen2D = function(pos)
  local _, sX, sY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
  return vector2(sX, sY)
end

local screenRelToWorld = function(camPos, camRot, cursor)
  local camForward = rotationToDirection(camRot)
  local rotUp = vector3(camRot.x + 1.0, camRot.y, camRot.z)
  local rotDown = vector3(camRot.x - 1.0, camRot.y, camRot.z)
  local rotLeft = vector3(camRot.x, camRot.y, camRot.z - 1.0)
  local rotRight = vector3(camRot.x, camRot.y, camRot.z + 1.0)
  local camRight = rotationToDirection(rotRight) - rotationToDirection(rotLeft)
  local camUp = rotationToDirection(rotUp) - rotationToDirection(rotDown)
  local rollRad = -(camRot.y * math.pi / 180.0)
  local camRightRoll = camRight * math.cos(rollRad) - camUp * math.sin(rollRad)
  local camUpRoll = camRight * math.sin(rollRad) + camUp * math.cos(rollRad)
  local point3DZero = camPos + camForward * 1.0
  local point3D = point3DZero + camRightRoll + camUpRoll
  local point2D = world3DToScreen2D(point3D)
  local point2DZero = world3DToScreen2D(point3DZero)
  local scaleX = (cursor.x - point2DZero.x) / (point2D.x - point2DZero.x)
  local scaleY = (cursor.y - point2DZero.y) / (point2D.y - point2DZero.y)
  local point3Dret = point3DZero + camRightRoll * scaleX + camUpRoll * scaleY
  local forwardDir = camForward + camRightRoll * scaleX + camUpRoll * scaleY
  return point3Dret, forwardDir
end

local function screenToWorldAsync(flag,ent,col,camRot,camPos,posX,posY)
  camRot  = camRot  or GetGameplayCamRot(0)
  camPos  = camPos  or GetGameplayCamCoord()
  posX    = posX    or 0.5
  posY    = posY    or 0.5

  local cursor = vector2(posX, posY)
  local cam3DPos, forwardDir = screenRelToWorld(camPos, camRot, cursor)
  local direction = camPos + (forwardDir * 100.0)

  local rayHandle = Citizen.InvokeNative(
    '0x7EE9F5D83DD4F90E', 
    cam3DPos.x,cam3DPos.y,cam3DPos.z, 
    direction.x,direction.y,direction.z, 
    flag or -1, 
    ent or 0, 
    col or 4
  )

  local res,hit,endCoords,surfaceNormal,entityHit = GetShapeTestResult(rayHandle)

  while res ~= 0 and res ~= 2 do
    res,hit,endCoords,surfaceNormal,entityHit = GetShapeTestResult(rayHandle)
    Wait(0)
  end

  return hit,endCoords,entityHit
end

local function screenToWorld(flag,ent,col,camRot,camPos,posX,posY)
  camRot  = camRot  or GetGameplayCamRot(0)
  camPos  = camPos  or GetGameplayCamCoord()
  posX    = posX    or 0.5
  posY    = posY    or 0.5

  local cursor = vector2(posX, posY)
  local cam3DPos, forwardDir = screenRelToWorld(camPos, camRot, cursor)
  local direction = camPos + (forwardDir * 100.0)

  local rayHandle = Citizen.InvokeNative(
    '0x377906D8A31E5586', 
    cam3DPos.x,cam3DPos.y,cam3DPos.z, 
    direction.x,direction.y,direction.z, 
    flag or -1, 
    ent or 0, 
    col or 4
  )

  local res,hit,endCoords,surfaceNormal,entityHit = GetShapeTestResult(rayHandle)

  return hit,endCoords,entityHit
end

s2w = {}
s2w.get = screenToWorld
s2w.getAsync = screenToWorldAsync