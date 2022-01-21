local apiRef = exports['bl-target']:getExportNames()

target = {}

for _,name in ipairs(apiRef) do
  target[name] = function(...)
    exports['bl-target'][name](exports['bl-target'],...)
  end
end