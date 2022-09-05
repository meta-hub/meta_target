local exportPrefix = 'fivem-target'

local function getExportEventName(name)
  return string.format('__cfx_export_%s_%s',exportPrefix,name)
end

local function onSelect(opts)
  return function(targetData,itemData,entHit)
    opts.onInteract(targetData.id,itemData.name,targetData.vars or {},entHit)
  end
end

local exports = {
  AddTargetEntity = function(opts)
    return mTarget.addNetEnt(opts.name,opts.label,opts.icon,opts.netId,opts.interactDist or false,onSelect(opts),opts.options,opts.vars,GetInvokingResource(),opts.canShow)
  end,

  AddTargetLocalEntity = function(opts)
    return mTarget.addLocalEnt(opts.name,opts.label,opts.icon,opts.entId,opts.interactDist or false,onSelect(opts),opts.options,opts.vars,GetInvokingResource(),opts.canShow)
  end,

  AddTargetPoint = function(opts) 
    return mTarget.addPoint(opts.name,opts.label,opts.icon,opts.point,opts.interactDist or false,onSelect(opts),opts.options,opts.vars,GetInvokingResource(),opts.canShow)
  end,

  AddTargetModel = function(opts) 
    return mTarget.addModel(opts.name,opts.label,opts.icon,opts.model,opts.interactDist or false,onSelect(opts),opts.options,opts.vars,GetInvokingResource(),opts.canShow)
  end,

  AddTargetModels = function(opts) 
    return mTarget.addModels(opts.name,opts.label,opts.icon,opts.models,opts.interactDist or false,onSelect(opts),opts.options,opts.vars,GetInvokingResource(),opts.canShow)
  end,

  AddPolyZone = function(opts)
    return mTarget.addExternalPoly(opts.name,opts.label,opts.icon,opts.interactDist or false,onSelect(opts),opts.options,opts.vars,GetInvokingResource(),opts.canShow)
  end,

  RemoveTargetPoint = function(name)
    return mTarget.removeTarget(name)
  end
}

for k,v in pairs(exports) do
  AddEventHandler(getExportEventName(k),function(cb)
    cb(v)
  end)
end