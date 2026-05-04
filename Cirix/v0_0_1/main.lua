-- wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/main.lua && main
local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting

----- SHORTENED FUNCTIONS -----
-- TODO: Add failsafes to movement and other functions
function f()robot.forward()end
function b()robot.back()end
function u()robot.up()end
function d()robot.down()end
function tr()robot.turnRight()end
function tl()robot.turnLeft()end
function ta()robot.turnAround()end
function getSlot(n)return ic.getStackInInternalSlot(n)end
function inv()return robot.inventorySize()end
function swapTo(n,n2)robot.transferTo(n,n2)end
function sel(n)robot.select(n)end
function place()robot.place()end
function placeU()robot.placeUp()end
function placeD()robot.placeDown()end
function swing()robot.swing()end
function swingU()robot.swingUp()end
function swingD()robot.swingDown()end
function equip()ic.equip()end

----- DATA -----
-- Special items (mutiple items with the same display name)
local itemMap = {
  ["Coke Oven Brick (Block)"] = {
    {label="Coke Oven Brick", name="Railcraft:machine.alpha"}
  },
  ["Coke Oven Brick (Brick)"] = {
    {name="dreamcraft:item.CokeOvenBrick"}
  },
  ["Advanced Coke Oven Brick (Block)"] = {
    {label="Advanced Coke Oven Brick", name="Railcraft:machine.alpha"}
  },
  ["Advanced Coke Oven Brick (Brick)"] = {
    {name="dreamcraft:item.AdvancedCokeOvenBrick"}
  }
}
-- Multiblock construction requirements (mostly used by canBuild())
-- Multiblock names are formatted as "name|tier"
local multiblocks = {
  ["Coke Oven"] = {
    {"Coke Oven Brick (Block)", 26}
  },
  ["Advanced Coke Oven"] = {
    {"Advanced Coke Oven Brick (Block)", 34}
  },
  ["Electric Blast Furnace"] = {
    {"Electric Blast Furnace", 1},
    {"Maintenance Hatch", 1},
    {"Input Bus (LV)", 1},
    {"Output Bus (LV)", 1},
    {"Input Hatch (LV)", 1},
    {"Output Hatch (LV)", 1},
    {"LV Energy Hatch", 2},
    {"Heat Proof Machine Casing", 9},
    {"Cupronickel Coil Block", 16},
    {"Muffler Hatch (LV)", 1}
  },
  ["Steam Grinder|1"] = {
    {"Steam Grinder", 1},
    {"Bronze Plated Bricks", 25}
  },
  ["Steam Grinder|2"] = {
    {"Steam Grinder", 1},
    {"Solid Steel Machine Casing", 25}
  },
  ["Steam Squasher|1"] = {
    {"Steam Squasher", 1},
    {"Bronze Plated Bricks", 33}
  },
  ["Steam Squasher|2"] = {
    {"Steam Squasher", 1},
    {"Solid Steel Machine Casing", 33}
  }
}

-- Crafting construction requirements
local craftingData = {
  ["Hammer"] = {
    {"Stick", 1},
    {"Iron Ingot", 6}
  },
  ["Wrench"] = {
    {"Hammer", 1},
    {"Iron Ingot", 6}
  },
  ["Stick"] = {
    {"Oak Planks", 2}
  },
  ["Oak Planks"] = {
    {"Oak Log", 1}
  },
  ["Coke Oven Brick (Block)"] = {
    {"Coke Oven Brick (Brick)", 4}
  }
}

----- HELPER ITEM OPERATIONS -----
----- ITEM MATCHING -----
function matches(stack, targetName)
  if not stack then return false end

  local defs = itemMap[targetName]

  if defs then
    for _, def in ipairs(defs) do
      local labelMatch = (not def.label) or (stack.label == def.label)
      local nameMatch  = (not def.name)  or (stack.name  == def.name)
      if labelMatch and nameMatch then return true end
    end
    return false
  end

  return stack.label == targetName
end

----- BASIC INVENTORY -----
function findItem(name)
  print("Finding item "..tostring(name))
  for slot = 1, inv() do
    if matches(getSlot(slot), name) then
      return slot
    end
  end
  return nil
end

function countItem(name)
  print("Counting item "..tostring(name))
  local total = 0
  for slot = 1, inv() do
    local stack = getSlot(slot)
    if matches(stack, name) then
      total = total + stack.size
    end
  end
  return total
end

function hasItem(name)
  print("Checking for item "..tostring(name))
  return countItem(name) > 0
end

----- SAFE SELECT -----
function selectItem(name)
  print("Selecting item "..tostring(name))
  if not ensureItem(name, 1) then
    error("Missing item: " .. tostring(name))
  end

  local slot = findItem(name)
  if not slot then
    error("Item vanished: " .. tostring(name))
  end

  sel(slot)
  return slot
end

----- ENSURE ITEM (CRAFTING CORE) -----
function ensureItem(name, amount)
  print("Ensuring item "..tostring(name).." with amount "..tostring(amount))
  amount = amount or 1

  if countItem(name) >= amount then
    return true
  end

  local recipe = craftingData[name]
  if not recipe then
    return false
  end

  local missing = amount - countItem(name)

  -- ensure ingredients first
  for _, req in ipairs(recipe) do
    local item, count = req[1], req[2]
    local needed = count * missing

    if countItem(item) < needed then
      if not ensureItem(item, needed) then
        return false
      end
    end
  end

  -- craft items
  for i = 1, missing do
    clearForCrafting()
    setUpCrafting(name)
    cr.craft(1)
  end

  return true
end


----- HELPER FUNCTIONS -----
-- Select empty
function unequip()
  for slot = 1,inv(),1 do
    if getSlot(slot) == nil then
      sel(slot)
      break
    end
  end
  -- TODO: Failsafe if no slots left
end

-- Can build multi
function canBuild(name, tier)
  -- Handle tiered multis
  if(tier) then
    tmp = name .. "|" .. tostring(tier)
  else
    tmp = name
  end
  -- Find the multi in data
  for _, req in ipairs(multiblocks[tmp]) do
    local item, count = req[1], req[2]
    if countItem(item) < count then
      return false
    end
  end
  -- Can build if nothing stopped the function
  return true
end

-- Singleblock setup
function setupMachine(machine, tier)
  if(machine == "Compressor") then
    if(tier == "LV" or tier == "ULV") then
      f()
      selectItem(("Dirt"))
      place()
      b()
      selectItem(("Hopper"))
      place()
      u()
      f()
      selectItem(("Basic Solar Panel"))
      place()
      b()
      selectItem(("Basic Compressor"))
      place()
      tr()
      f()
      tl()
      selectItem(("Hopper"))
      place()
      tl()
      f()
      tr()
      d()
    end
  end
end

-- Singleblock dismantle
function dismantleMachine(machine)
  if(machine == "Compressor") then
    selectItem(("Vajra"))
    equip()
    u()
    swing()
    f()
    swingD()
    swing()
    tr()
    swing()
    tl()
    f()
    swingD()
    d()
    b()
    b()
  end
end

-- Crafting
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
    selectItem(("Iron Ingot"))
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
    swapTo(9, 1)
    swapTo(10, 1)
    selectItem(("Stick"))
    swapTo(7, 1)
  end
  if(name == "Wrench") then
    selectItem(("Iron Ingot"))
    swapTo(1, 1)
    swapTo(3, 1)
    swapTo(5, 1)
    swapTo(6, 1)
    swapTo(7, 1)
    swapTo(10, 1)
    selectItem(("Hammer"))
    swapTo(2, 1)
  end
  if(name == "Coke Oven Brick (Block)") then
    selectItem(("Coke Oven Brick (Brick)"))
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
  end
  if(name == "Stick") then
    selectItem(("Oak Planks"))
    swapTo(1, 1)
    swapTo(2, 1)
  end
  if(name == "Oak Planks") then
    selectItem(("Oak Log"))
    swapTo(1, 1)
  end
  if(name == "2x2") then
    selectItem(material)
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
  end
  if(name == "1x1") then
    selectItem(material)
    swapTo(1, 1)
  end
  if(name == "1x2") then
    selectItem(material)
    swapTo(1, 1)
    swapTo(2, 1)
  end
end

----- SIMPLE CRAFT WRAPPER -----
function craft(name, _, amount)
  print("Crafting item "..tostring(name).." with amount "..tostring(amount))
  amount = amount or 1
  return ensureItem(name, amount)
end

-- Compressing
function compress(nam, n)
  setupMachine("Compressor", "ULV")  -- TODO: Add handling to use compressors from other tiers
  local checks = 0

  -- Go to input
  u()
  tr()
  f()
  tl()

  -- Add input
  if(nam == "Advanced Coke Oven Brick (Block)") then
    for i=1,(4*n)//64 do
      selectItem("Advanced Coke Oven Brick (Brick)")
      robot.drop(64)
    end
    selectItem("Advanced Coke Oven Brick (Brick)")
    robot.drop((4*n) - (64 * ((4*n)//64)))
  end

  -- Go to output
  tl()
  f()
  tr()
  d()

  -- Start cycle
  selectItem("Vajra")
  equip()
  selectItem("Hopper")
  local continue = true
  while continue do
    robot.swing()
    robot.place()
    checks = checks + 1
    if checks % 10 == 0 then  -- refresh every 10 cycles
      if(countItem(nam) >= n) then
        continue = false
      end
    end
  end

  -- Finish
  dismantleMachine("Compressor")
end

-- Construction
function square3()
  f()
  f()
  f()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  place()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  place()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  place()
end
function square3H()
  f()
  f()
  f()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  place()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  place()
end
function square3V()
  place()
  u()
  place()
  u()
  place()
  tr()
  f()
  tl()
  place()
  d()
  place()
  d()
  place()
  tl()
  f()
  f()
  tr()
  place()
  u()
  place()
  u()
  place()
  d()
  d()
  tr()
  f()
  tl()
end
function square3HV()
  place()
  u()
  u()
  place()
  tr()
  f()
  tl()
  place()
  d()
  place()
  d()
  place()
  tl()
  f()
  f()
  tr()
  place()
  u()
  place()
  u()
  place()
  d()
  d()
  tr()
  f()
  tl()
end

-- Multis
function buildEBF() --Using old code because new doesn't work
  f()
  f()
  f()
  f()
  ta()
  selectItem(("LV Energy Hatch"))
  place()
  tr()
  f()
  tl()
  place()
  tl()
  f()
  f()
  tr()
  selectItem(("Heat Proof Machine Casing"))
  place()
  tl()
  f()
  tr()
  f()
  f()
  tr()
  selectItem(("Maintenance Hatch"))
  place()
  tl()
  f()
  f()
  tr()
  f()
  tr()
  selectItem(("Input Hatch (LV)"))
  place()
  tl()
  f()
  f()
  f()
  tr()
  f()
  f()
  tr()
  selectItem(("Output Bus (LV)"))
  place()
  tr()
  f()
  tl()
  selectItem(("Input Bus (LV)"))
  place()
  tr()
  f()
  tl()
  f()
  f()
  tl()
  f()
  selectItem(("Heat Proof Machine Casing"))
  place()
  b()
  selectItem(("Electric Blast Furnace"))
  place()
  
  selectItem(("Cupronickel Coil Block"))
  for i = 1,2,1 
  do
    u()
    f()
    f()
    f()
    tr()
    place()
    ta()
    place()
    tr()
    b()
    place()
    tr()
    place()
    ta()
    place()
    tr()
    b()
    tr()
    place()
    ta()
    place()
    tr()
    b()
    place()
  end
  
  u()
  f()
  f()
  f()
  tr()
  selectItem(("Heat Proof Machine Casing"))
  place()
  ta()
  place()
  tr()
  b()
  place()
  tr()
  place()
  ta()
  place()
  tr()
  u()
  selectItem(("Muffler Hatch (LV)"))
  placeD()
  selectItem(("Wrench"))
  equip()
  robot.useDown(1)
  unequip()
  equip()
  b()
  d()
  tr()
  selectItem(("Heat Proof Machine Casing"))
  place()
  ta()
  place()
  tr()
  b()
  selectItem(("Output Hatch (LV)"))
  place()
  
  d()
  d()
  d()
  tr()
  f()
  f()
  tl()
  f()
  f()
  tl()
  selectItem(("BrainTech Aerospace Advanced Reinforced Duct Tape FAL-84"))
  equip()
  robot.use(2)
  unequip()
  equip()
  tl()
  f()
  f()
  tr()
  f()
  f()
  tr()
end
function buildCokeOven()
  selectItem(("Coke Oven Brick (Block)"))
  square3()
  u()
  square3H()
  u()
  square3()
  d()
  d()
end
function buildAdvancedCokeOven()
  selectItem(("Advanced Coke Oven Brick (Block)"))
  square3()
  u()
  square3H()
  u()
  square3H()
  u()
  square3()
  d()
  d()
  d()
end
function buildSteamGrinder(tier)
  if(tier == 1) then
    selectItem(("Bronze Plated Bricks"))
  elseif(tier == 2) then
    selectItem(("Solid Steel Machine Casing"))
  end
  square3()
  u()
  f()
  f()
  f()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  place()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  tr()
  place()
  ta()
  place()
  tr()
  b()
  selectItem(("Steam Grinder"))
  place()
  u()
  if(tier == 1) then
    selectItem(("Bronze Plated Bricks"))
  elseif(tier == 2) then
    selectItem(("Solid Steel Machine Casing"))
  end
  square3()
  d()
  d()
end
function buildSteamSquasher(tier)
  if(tier == 1) then
    selectItem(("Bronze Plated Bricks"))
  elseif(tier == 2) then
    selectItem(("Solid Steel Machine Casing"))
  end
  f()
  f()
  f()
  square3V()
  b()
  square3HV()
  b()
  square3HV()
  b()
  square3HV()
  u()
  selectItem(("Steam Squasher"))
  place()
  d()
end

-- Movement
function moveToNext3_3Side()
  tl()
  f()
  f()
  f()
  f()
  tr()
end
function moveToNext3_3Front()
  tl()
  f()
  f()
  tr()
  f()
  f()
  f()
  f()
  f()
  tr()
  f()
  f()
  tl()
end
function moveToNext3_3Back()
  tl()
  f()
  f()
  tl()
  f()
  f()
  f()
  f()
  f()
  tl()
  f()
  f()
  tl()
end

----- IDK -----
function ovens()
  for i = 1,24,1 do
    for i2 = 1,24,1 do
      buildCokeOven()
      moveToNext3_3Front()
    end
    for i2 = 1,24,1 do
      moveToNext3_3Back()
    end
    tr()
    f()
    f()
    f()
    f()
    tl()
  end
  for i = 1,24,1 do
    tl()
    f()
    f()
    f()
    f()
    tr()
  end
end

----- MAIN CODE -----
if(hasItem("Dimensionally Transcendent Plasma Forge")) then
  ovens()
else
  ensureItem("Wrench", 1)
  if(countItem("Coke Oven Brick (Block)") < 26) then
    craft("2x2","Coke Oven Brick (Brick)",26)
  end
  if(countItem("Advanced Coke Oven Brick (Block)") < 34) then
    compress("Advanced Coke Oven Brick (Block)",34)
  end
  tr()
  f()
  f()
  f()
  f()
  f()
  tl()
  if(canBuild("Electric Blast Furnace")) then
    buildEBF()
  end
  moveToNext3_3Front()
  if(canBuild("Coke Oven")) then
    buildCokeOven()
  end
  moveToNext3_3Front()
  if(canBuild("Advanced Coke Oven")) then
    buildAdvancedCokeOven()
  end
  moveToNext3_3Front()
  if(canBuild("Steam Grinder", 2)) then
    buildSteamGrinder(2)
  elseif(canBuild("Steam Grinder", 1)) then
    buildSteamGrinder(1)
  end
  moveToNext3_3Front()
  if(canBuild("Steam Squasher", 2)) then
    buildSteamSquasher(2)
  elseif(canBuild("Steam Squasher", 1)) then
    buildSteamSquasher(1)
  end
  moveToNext3_3Back()
  moveToNext3_3Back()
  moveToNext3_3Back()
  tl()
  f()
  f()
  f()
  tr()
end
