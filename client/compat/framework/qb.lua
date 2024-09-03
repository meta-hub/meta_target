local frameWork = {}
local frameWorkName = 'qb-core'
local currentResource = GetCurrentResourceName()
local validStates = {
  ["started"] = true,
  ["starting"] = true,
}
if not validStates[GetResourceState(frameWorkName)] then return end
-- for record im not using qb core that i wrote it whole from code i saw and docs btw if you know better way to do it please tell or make PR

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
  local startingData = frameWork.GetCoreObject()
  frameWork.ready(startingData)
end

function frameWork.getStartingData()
  local data = {
    jobName = frameWork.object.GetPlayerData() and frameWork.object.GetPlayerData().job and frameWork.object.GetPlayerData().job.name,
    jobGrade = frameWork.object.GetPlayerData() and frameWork.object.GetPlayerData().job and frameWork.object.GetPlayerData().job.grade,
  }
  return data
end

AddEventHandler('QBCore:Player:SetPlayerData', function(val)
  if GetInvokingResource() == frameWorkName then
    if val.key == "job" then
      local data = {
        jobName = val.job.name,
        jobGrade = val.gang.name,
      }
      frameWork.update(data)
    end
  end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function(xPlayer)
  if not frameWork.object then
    frameWork.getObject()
  elseif not frameWork.ready then
    frameWork.reLoad()
  end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
  frameWork.unLoad()
end)

CreateThread(frameWork.getObject)