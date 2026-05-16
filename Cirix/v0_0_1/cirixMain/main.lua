-- wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/main.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/misc.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/inventoryManager.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/crafting.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/building.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/movement.lua

----- IMPORTS -----
local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting
require("misc")
require("inventoryManager")
require("crafting")
require("building")
require("movement")

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
  unselect()
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
  unselect()
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
  selectItem("Steam Grinder")
  place()
  u()
  if(tier == 1) then
    selectItem("Bronze Plated Bricks")
  elseif(tier == 2) then
    selectItem("Solid Steel Machine Casing")
  end
  square3()
  d()
  d()
end
function buildSteamSquasher(tier)
  if(tier == 1) then
    selectItem("Bronze Plated Bricks")
  elseif(tier == 2) then
    selectItem("Solid Steel Machine Casing")
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

-- Select a new filler block to use
function setFillerSlot()
  if hasItem("Cobblestone") then
    lastFillerSlot = findItem("Cobblestone")
    sel(lastFillerSlot)  -- Not using selectItem since the item is checked to exist and this would run findItem twice
  else
    -- Set filler slot to nothing to indicate that there is no cobblestone left
    lastFillerSlot = nil
  end
end

-- Selects a new filler, lastFillerSlot would become nil if this failed
function selectFiller()
  if lastFillerSlot then  -- If there was a filler already selected
    local lastFillerData = getSlot(lastFillerSlot)  -- Update stack data
    if lastFillerData then  -- If there are still items in the stack
      if lastFillerData.name ~= "minecraft:cobblestone" then  -- If it is no longer the filler
        setFillerSlot()  -- Select a new filler (slot no longer has the filler)
      end
    else
      setFillerSlot()  -- Select a new filler (slot is empty)
    end
  else
    setFillerSlot()  -- Select a new filler (no filler selected)
  end
end

-- Unload items
function unloadAll()
  local currentInv = inv()  -- Get the current inventory state
  for slot = 1, currentInv do  -- Iterate through the inventory
    robot.select(slot)
    robot.drop()
  end
end

-- Unload items except the Vajra and fillers (cobblestone)
function unloadAllNonTool()
  local currentInv = inv()  -- Get the current inventory state
  for slot = 1, currentInv do  -- Iterate through the inventory
    local item = getSlot(slot)
    if item then
      if (item.label ~= "Vajra") and (item.name ~= "minecraft:cobblestone") then
        robot.select(slot)
        robot.drop()
      end
    end
  end
end
function unloadAllNonToolU()
  local currentInv = inv()  -- Get the current inventory state
  for slot = 1, currentInv do  -- Iterate through the inventory
    local item = getSlot(slot)
    if item then
      if (item.label ~= "Vajra") and (item.name ~= "minecraft:cobblestone") then
        robot.select(slot)
        robot.dropUp()
      end
    end
  end
end

-- Takes in everything
function loadAllF()
  while robot.suck() do

  end
end
function loadAllU()
  while robot.suckUp() do

  end
end
function loadAllD()
  while robot.suckDown() do

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
  selectItem("Cobblestone")
  place()
  u()
  place()
  d()
  selectItem("Gold Chest")
  placeU()
  unselect()
  equip()
  selectItem("Vajra")
  equip()
  swing()
  f()
  swingU()
  b()
  
  findBlock("Sand")
  origin()
  unloadAllNonToolU()
  lastFillerSlot = nil
  
  findBlock("Sand")
  origin()
  unloadAllNonToolU()
  lastFillerSlot = nil
  
  findBlock("Clay")
  origin()
  unloadAllNonToolU()
  lastFillerSlot = nil
  
  findBlock("Clay")
  origin()
  unloadAllNonToolU()

  loadAllU()
  alloySmelt("Coke Oven Brick (Brick)", 4)

  craft("Coke Oven Brick (Block)","Coke Oven Brick (Brick)", 1)
end