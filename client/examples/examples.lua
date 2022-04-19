local function onSelect(t,o)
  print(t.id,o.name)
end

local dumpsterModels = {
  "prop_cs_dumpster_01a",
  "p_dumpster_t",
  "prop_snow_dumpster_01",
  "prop_dumpster_01a",
  "prop_dumpster_02a",
  "prop_dumpster_02b",
  "prop_dumpster_3a",
  "prop_dumpster_4a",
  "prop_dumpster_4b",
}

  mTarget.addModels("dumpster","Dumpster","fas fa-dumpster",dumpsterModels,2.0,onSelect,{
    {
      name = "search_dumpster",
      label = "Search Dumpster"
    }
  })

  mTarget.addPlayer('ply', 'Ply', 'fas fa-car', 10.0, onSelect, {
    {
      name = 'lock_door',
      label = 'Lock Door'
    }
  })

  mTarget.addPed('ped', 'Ped', 'fas fa-car', 10.0, onSelect, {
    {
      name = 'lock_door',
      label = 'Lock Door'
    }
  })

  mTarget.addVehicle('veh', 'Veh', 'fas fa-car', 10.0, onSelect, {
    {
      name = 'lock_door',
      label = 'Lock Door'
    }
  })

  mTarget.addObject('obj', 'Obj', 'fas fa-car', 10.0, onSelect, {
    {
      name = 'lock_door',
      label = 'Lock Door'
    }
  })
