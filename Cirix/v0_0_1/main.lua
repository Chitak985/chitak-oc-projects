-- wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/main.lua && main
local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting

----- SHORTENED FUNCTIONS -----
function getSlot(n)return ic.getStackInInternalSlot(n)end
function inv()return robot.inventorySize()end
function swapTo(n,n2)robot.transferTo(n,n2)end
function sel(n)return robot.select(n)end
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
    label="Coke Oven Brick",
    name="Railcraft:machine.alpha"
  },
  ["Coke Oven Brick (Brick)"] = {
    name="dreamcraft:item.CokeOvenBrick"
  },
  ["Advanced Coke Oven Brick (Block)"] = {
    label="Advanced Coke Oven Brick",
    name="Railcraft:machine.alpha"
  },
  ["Advanced Coke Oven Brick (Brick)"] = {
    name="dreamcraft:item.AdvancedCokeOvenBrick"
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

----- INVENTORY -----
function findItem(name)  -- Find an item in the inventory
  local mapEntry = itemMap[name]  -- Get the entry in the special items, nil if it is not a special item
  local currentInv = inv()  -- Get the current inventory state

  for slot = 1, currentInv do  -- Iterate through the inventory
    local item = getSlot(slot)  -- Get item in the slot, nil if the slot is empty

    if item then  -- Make sure slot is not empty
      if mapEntry then  -- Only run if special item
        if mapEntry.label then  -- If it has a display name (.label), the item's internal name is duplicated somewhere
          if item.label == mapEntry.label and item.name == mapEntry.name then
            return slot
          end
        else  -- Normal special item handling, use internal name instead of display name
          if item.name == mapEntry.name then
            return slot
          end
        end
      else  -- Normal item handling, use display name
        if item.label == name then
          return slot
        end
      end
    end
  end

  return nil
end

function countItem(name)
  local total = 0
  local mapEntry = itemMap[name]  -- Get the entry in the special items, nil if it is not a special item
  local currentInv = inv()  -- Get the current inventory state

  for slot = 1, currentInv do  -- Iterate through the inventory
    local item = getSlot(slot)  -- Get item in the slot, nil if the slot is empty

    if item then  -- Make sure slot is not empty
      if mapEntry then  -- Only run if special item
        if mapEntry.label then  -- If it has a display name (.label), the item's internal name is duplicated somewhere
          if item.label == mapEntry.label and item.name == mapEntry.name then
            total = total + item.size
          end
        else  -- Normal special item handling, use internal name instead of display name
          if item.name == mapEntry.name then
            total = total + item.size
          end
        end
      else  -- Normal item handling, use display name
        if item.label == name then
          total = total + item.size
        end
      end
    end
  end

  return total
end

function hasItem(name)
  return findItem(name) ~= nil
end

function selectItem(name)
  local slot = findItem(name)
  if not slot then
    print("selectItem("..tostring(name).."): Item not found: "..tostring(name))
    return nil
  end
  return sel(slot)
end

----- ENSURE ITEM (CRAFTING CORE) -----
function ensureItem(name, amount)
  print("ensureItem("..tostring(name)..", "..tostring(amount)..") called!")
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
  print("unequip(): No slots left!")
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
    if(tier == "LV" or tier == "ULV") then  -- Starts under the compressor
      selectItem("Dirt")
      place()
      u()
      selectItem("Basic Solar Panel")
      place()
      b()
      selectItem("Basic Compressor")
      place()
      d()
      selectItem("Hopper")
      placeU()  -- End under the input hopper (1 block back)
    end
  end
end

-- Singleblock dismantle
function dismantleMachine(machine)
  if(machine == "Compressor") then  -- Must start under the input hopper
    selectItem("Vajra")
    equip()
    swingU()
    f()
    swingU()
    swing()
    f()
    swingU()  -- End where the dirt was (1 block forward from the compressor, 2 forward from input hopper)
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

-- Compressing
function compress(nam, n)
  setupMachine("Compressor", "ULV")  -- TODO: Add handling to use compressors from other tiers
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

----- NAVIGATION -----
-- Data
--Rotation:
--  Z
--  1
--4   2 X
--  3
posX = 0
posY = 0
posZ = 0
rotation = 1

-- Movement Functions
--TODO: Add failsafes to movement and other functions
function f()  -- Forward
  robot.forward()
  if(rotation == 1) then
    posZ = posZ + 1
  elseif(rotation == 2) then
    posX = posX + 1
  elseif(rotation == 3) then
    posZ = posZ - 1
  elseif(rotation == 4) then
    posX = posX - 1
  end
end
function b()  -- Back
  robot.back()
  if(rotation == 1) then
    posZ = posZ - 1
  elseif(rotation == 2) then
    posX = posX - 1
  elseif(rotation == 3) then
    posZ = posZ + 1
  elseif(rotation == 4) then
    posX = posX + 1
  end
end
function u()  -- Up
  robot.up()
  posY = posY + 1
end
function d()  -- Down
  robot.down()
  posY = posY - 1
end
function tr()  -- Turn Right
  robot.turnRight()
  rotation = rotation + 1
  if(rotation == 5) then
    rotation = 1
  end
end
function tl()  -- Turn Left
  robot.turnLeft()
  rotation = rotation - 1
  if(rotation == 0) then
    rotation = 4
  end
end
function ta()  -- Turn Around
  robot.turnAround()
  rotation = rotation + 2
  if(rotation == 5) then
    rotation = 1
  elseif(rotation == 6) then
    rotation = 2
  end
end

-- Return to the 0,0,0 position (origin)
--First matches y, then x, then z
function origin()
  unequip()
  equip()
  selectItem("Vajra")
  equip()
  -- Y -> 0
  while posY > 0 do
    if robot.detectDown()[0] then
      robot.swingDown()
    end
    d()
  end
  while posY < 0 do
    if robot.detectUp()[0] then
      robot.swingUp()
    end
    u()
  end
  
  -- Face towards X+
  while rotation != 2 do
    tr()
  end
  
  -- X -> 0 (negative)
  while posX < 0 do
    if robot.detect()[0] then
      robot.swing()
    end
    f()
  end
  
  -- Face towards X-
  ta()
  
  -- X -> 0 (positive)
  while posX > 0 do
    if robot.detect()[0] then
      robot.swing()
    end
    f()
  end
  
  -- Face towards Z+
  tr()
  
  -- X -> 0 (negative)
  while posZ < 0 do
    if robot.detect()[0] then
      robot.swing()
    end
    f()
  end
  
  -- Face towards Z-
  ta()
  
  -- X -> 0 (positive)
  while posZ > 0 do
    if robot.detect()[0] then
      robot.swing()
    end
    f()
  end
end

----- MAIN CODE -----
if(hasItem("Dimensionally Transcendent Plasma Forge")) then
  ovens()
elseif(hasItem("Electric Blast Furnace")) then
  cokeOvenBlocks = countItem("Coke Oven Brick (Block)")
  advCokeOvenBlocks = countItem("Advanced Coke Oven Brick (Block)")

  if not hasItem("Wrench") then
    if not hasItem("Hammer") then
      if not hasItem("Stick") then
        if not hasItem("Oak Planks") then
          craft("Oak Planks")
        end
        craft("Stick")
      end
      craft("Hammer")
    end
    craft("Wrench")
  end
  
  if(cokeOvenBlocks < 26) then
    craft("Coke Oven Brick (Block)","Coke Oven Brick (Brick)", 26-cokeOvenBlocks)
  end
  if(advCokeOvenBlocks < 34) then
    compress("Advanced Coke Oven Brick (Block)", 34-advCokeOvenBlocks)
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
else
  selectItem("Gold Chest")
  place()
  selectItem("Vajra")
  equip()
end
