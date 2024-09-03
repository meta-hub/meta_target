local frameWork = {}
local frameWorkName = 'es_extended'
local currentResource = GetCurrentResourceName()
local validStates = {
  ["started"] = true,
  ["starting"] = true,
}
if not validStates[GetResourceState(frameWorkName)] then return end

function frameWork.ready(startingData)
  frameWork.ready = true
  TriggerEvent(currentResource .. ":frameworkReady", startingData)
end

function frameWork.unLoad()
  frameWork.ready = false
  TriggerEvent(currentResource .. ":frameworkUnLoad")
end

function frameWork.reLoad()
  frameWork.ready = true
  local startingData = frameWork.getStartingData()
  TriggerEvent(currentResource .. ":frameworkReady", startingData)
end

function frameWork.update(newData)
  TriggerEvent(currentResource .. ":frameworkChange", newData)
end

function frameWork.getObject()
  frameWork.object = exports[frameWorkName]:getSharedObject()
  local startingData = frameWork.getStartingData()
  frameWork.ready(startingData)
end

function frameWork.getStartingData()
  while frameWork.object.GetPlayerData().job == nil do
    Wait(10)
  end
  local data = {
    jobName = frameWork.object.GetPlayerData().job.name,
    jobGrade = frameWork.object.GetPlayerData().job.grade,
  }
  return data
end

AddEventHandler('esx:setPlayerData', function(key, val, last)
  if GetInvokingResource() == frameWorkName then
    if key == "job" then
      local data = {
        jobName = val.name,
        jobGrade = val.grade,
      }
      frameWork.update(data)
    end
  end
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
  if not frameWork.object then
    frameWork.getObject()
  elseif not frameWork.ready then
    frameWork.reLoad()
  end
end)

RegisterNetEvent('esx:onPlayerLogout', function()
  frameWork.unLoad()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  local data = {
    jobName = job.name,
    jobGrade = job.grade,
  }
  frameWork.update(data)
end)

CreateThread(frameWork.getObject)