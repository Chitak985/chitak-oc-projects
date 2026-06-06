----- IMPORTS -----
local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting

----- SINGLEBLOCK SETUP -----
function setupMachine(machine, tier)
  prepareSetupMachine(machine, tier)
  equipSafe("Wrench")
  if(machine == "Compressor") then
    if(tier == "LV" or tier == "ULV") then  -- Starts under the compressor
      u()
      selectItem("Basic Solar Panel")
      place()
      b()
      selectItem("Basic Compressor")
      place()
      robot.useUp(5, true)
      d()
      selectItem("Hopper")
      placeU()  -- End under the input hopper (1 block back)
    end
  elseif(machine == "Alloy Smelter") then
    if(tier == "LV" or tier == "ULV") then  -- Starts under the compressor
      u()
      selectItem("Basic Solar Panel")
      place()
      b()
      selectItem("Basic Alloy Smelter")
      place()
      robot.useUp(5, true)
      d()
      selectItem("Hopper")
      placeU()  -- End under the input hopper (1 block back)
    end
  elseif(machine == "EFurnace") then
    if(tier == "LV" or tier == "ULV") then  -- Starts under the furnace
      u()
      selectItem("Basic Solar Panel")
      place()
      b()
      selectItem("Basic Electric Furnace")
      place()
      robot.useUp(5, true)
      d()
      selectItem("Hopper")
      placeU()  -- End under the input hopper (1 block back)
    end
  end
end

----- SINGLEBLOCK SETUP PREPARATIONS -----
function prepareSetupMachine(machine, tier)
  equipSafe("Vajra")
  if(machine == "Compressor") then
    if(tier == "LV" or tier == "ULV") then  -- Starts under the machine
      swingU()
      u()
      swing()
      ta()
      swing()
      ta()
      d()  -- Return back under the machine
    end
  elseif(machine == "Alloy Smelter") then
    if(tier == "LV" or tier == "ULV") then  -- Starts under the machine
      swingU()
      u()
      swing()
      ta()
      swing()
      ta()
      d()  -- Return back under the machine
    end
  elseif(machine == "EFurnace") then
    if(tier == "LV" or tier == "ULV") then  -- Starts under the machine
      robot.swing()
      robot.swingUp()
      u()
      robot.swing()
      ta()
      robot.swing()
      ta()
      d()  -- Return back under the machine
    end
  end
end

----- SINGLEBLOCK DISMANTLE -----
function dismantleMachine(machine)
  equipSafe("Vajra")
  if(machine == "Compressor") then  -- Must start under the input hopper
    swingU()
    f()
    swingU()
    swing()
    f()
    swingU()  -- End where the cobble was (1 block forward from the compressor, 2 forward from input hopper)
  elseif(machine == "Alloy Smelter") then  -- Must start under the input hopper
    swingU()
    f()
    swingU()
    swing()
    f()
    swingU()  -- End where the cobble was (1 block forward from the compressor, 2 forward from input hopper)
  elseif(machine == "EFurnace") then  -- Must start under the input hopper
    swingU()
    f()
    swingU()
    swing()
    f()
    swingU()  -- End where the cobble was (1 block forward from the compressor, 2 forward from input hopper)
  end
end

----- CRAFTING -----
function clearForCrafting()
  for slot = 1,12,1
  do
    if(getSlot(slot)) then
      sel(slot)
      local size = inv()  -- Optimization... somehow
      for i = 14,size do
        if(getSlot(i) == nil) then
          swapTo(i)
          break
        end
      end
    end
  end
end
function setUpCrafting(name, material)
  -- TODO: Use tables for crafting layouts
  if(name == "Hammer") then
    selectItem("Iron Ingot")
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
    swapTo(9, 1)
    swapTo(10, 1)
    selectItem("Stick")
    swapTo(7, 1)
  end
  if(name == "Wrench") then
    selectItem("Iron Ingot")
    swapTo(1, 1)
    swapTo(3, 1)
    swapTo(5, 1)
    swapTo(6, 1)
    swapTo(7, 1)
    swapTo(10, 1)
    selectItem("Hammer")
    swapTo(2, 1)
  end
  if(name == "Coke Oven Brick (Block)") then
    selectItem("Coke Oven Brick (Brick)")
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
  end
  if(name == "Unfired Coke Oven Brick") then
    selectItem("Clay")
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(3, 1)
    selectItem("Sand")
    swapTo(5, 1)
    swapTo(7, 1)
    swapTo(9, 1)
    swapTo(10, 1)
    swapTo(11, 1)
    selectItem("Wooden Form (Brick)")
    swapTo(6, 1)
  end
  if(name == "Wooden Form (Brick)") then
    selectItem("Knife")
    swapTo(1, 1)
    selectItem("Blank Pattern")
    swapTo(2, 1)
  end
  if(name == "Knife") then
    selectItem("Flint")
    swapTo(1, 1)
    selectItem("Stick")
    swapTo(5, 1)
  end
  if(name == "Blank Pattern") then
    selectItem("Paper")
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
  end
  if(name == "Stick") then
    selectItem("Oak Planks")
    swapTo(1, 1)
    swapTo(5, 1)
  end
  if(name == "Oak Planks") then
    selectItem("Oak Log")
    swapTo(1, 1)
  end

  -- Obsolete
  if(name == "2x2") then
    print("2x2 crafting pattern called!")
    selectItem(material)
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
  end
  if(name == "1x1") then
    print("1x1 crafting pattern called!")
    selectItem(material)
    swapTo(1, 1)
  end
  if(name == "1x2") then
    print("1x2 crafting pattern called!")
    selectItem(material)
    swapTo(1, 1)
    swapTo(2, 1)
  end
end
function craft(name, _, amount)
  amount = amount or 1
  for i = 1,amount,1 do
    clearForCrafting()
    setUpCrafting(name)
    cr.craft(1)
  end
end

------ COMPRESSING -----
function compress(nam, n)
  setupMachine("Compressor", "ULV")  -- TODO: Add handling to use machines from other tiers
  local checks = 0

  -- Add input
  if(nam == "Advanced Coke Oven Brick (Block)") then
    for i=1,(4*n)//64 do
      selectItem("Advanced Coke Oven Brick (Brick)")
      robot.dropUp(64)
    end
    selectItem("Advanced Coke Oven Brick (Brick)")
    robot.dropUp((4*n) - (64 * ((4*n)//64)))
  end

  -- Go to output
  f()

  -- Start cycle
  while true do
    robot.suckUp()
    checks = checks + 1
    if checks % 10 == 0 then  -- refresh every 10 cycles
      if(countItem(nam) >= n) then
        break
      end
    end
  end

  -- Go to input
  b()
  
  -- Finish
  dismantleMachine("Compressor")
end

----- ALLOY SMELTING -----
function alloySmelt(nam, n)
  setupMachine("Alloy Smelter", "ULV")  -- TODO: Add handling to use machines from other tiers
  local checks = 0

  -- Add input
  if(nam == "Coke Oven Brick (Brick)") then
    selectItem("Sand")
    robot.dropUp(n // 0.5)
    selectItem("Clay")
    robot.dropUp(n // 0.5)
  end

  -- Go to output
  f()

  -- Start cycle
  while true do
    robot.suckUp()
    checks = checks + 1
    if checks % 10 == 0 then  -- refresh every 10 cycles
      if(countItem(nam) >= n) then
        break
      end
    end
  end

  -- Go to input
  b()
  
  -- Finish
  dismantleMachine("Alloy Smelter")
end

----- SMELTING -----
function smelt(nam, n)
  setupMachine("EFurnace", "ULV")  -- TODO: Add handling to use machines from other tiers and a normal furnace
  local checks = 0

  -- Add input
  if(nam == "Coke Oven Brick (Brick)") then
    selectItem("Unfired Coke Oven Brick")
    robot.dropUp(n)
  end

  -- Go to output
  f()

  -- Start cycle
  while true do
    robot.suckUp()
    checks = checks + 1
    if checks % 10 == 0 then  -- refresh every 10 cycles
      if(countItem(nam) >= n) then
        break
      end
    end
  end

  -- Go to input
  b()
  
  -- Finish
  dismantleMachine("EFurnace")
end
