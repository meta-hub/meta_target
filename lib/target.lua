local apiRef = exports.meta_target:getExportNames()

target = {}

for _,name in ipairs(apiRef) do
  target[name] = function(...)
    exports.meta_target[name](exports['bl-target'],...)
  end
end
