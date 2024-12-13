local frameWork = {}
local frameWorkName = 'YouResourceName'
local currentResource = GetCurrentResourceName()
local validStates = {
  ["started"] = true,
  ["starting"] = true,
}
if not validStates[GetResourceState(frameWorkName)] then return end
-- Checks if the resource is started or starting, if not, it will not load the framework.

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
  frameWork.object = callToFetchCore()
  local startingData = {
    jobName = AnyHowWantGetJobName(), -- as string
    jobGrade = AnyHowWantGetJobGrade(), -- as number
  }
  frameWork.ready(startingData)
end

function frameWork.getStartingData()
  local data = {
    jobName = AnyHowWantGetJobName(), -- as string
    jobGrade = AnyHowWantGetJobGrade(), -- as number
  }
  return data
end

AddEventHandler('Event For Change Player Data From Core', function(val)
  local data = {
    jobName = AnyHowWantGetJobName(), -- as string
    jobGrade = AnyHowWantGetJobGrade(), -- as number
  }
  frameWork.update(data)
end)

RegisterNetEvent('Event For Player Load', function(MaybePlayerData)
  if not frameWork.object then
    frameWork.getObject()
  elseif not frameWork.ready then
    frameWork.reLoad()
  end
end)

RegisterNetEvent('Event For Player Unload From Core', function()
  frameWork.unLoad()
end)

Citizen.CreateThread(frameWork.getObject)