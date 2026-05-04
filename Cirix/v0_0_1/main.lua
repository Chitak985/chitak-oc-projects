-- wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/main.lua && main
-- TODO: Replace sel(findItem("e")) to avoid findItem returning nil and breaking everything
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
    {"Oak Log", 2}
  },
  ["Coke Oven Brick (Block)"] = {
    {"Coke Oven Brick", 4}
  }
}

----- HELPER ITEM OPERATIONS -----
-- Matching
function matches(stack, targetName)
  if not stack then return false end

  local defs = itemMap[targetName]

  -- If special definition exists, use it
  if defs then
    for _, def in ipairs(defs) do
      local labelMatch = (not def.label) or (stack.label == def.label)
      local nameMatch  = (not def.name)  or (stack.name  == def.name)

      if labelMatch and nameMatch then
        return true
      end
    end
    return false
  end

  -- Default behavior: match by display name
  return stack.label == targetName
end

-- Find item
function findItem(targetName)
  local size = inv()
  for slot = 1, size do
    if matches(getSlot(slot), targetName) then
      return slot
    end
  end

  if(canCraft(targetName)) then
    craft(targetName, nil, 1)
  end

  -- Try again after crafting the item
  local size = inv()
  for slot = 1, size do
    if matches(getSlot(slot), targetName) then
      return slot
    end
  end
end

-- Has item
function hasItem(targetName)
  return findItem(targetName) ~= nil
end

-- Count an item
function countItem(targetName)
  local count = 0
  local size = inv()

  for slot = 1, size do
    local stack = getSlot(slot)
    if matches(stack, targetName) then
      count = count + stack.size
    end
  end

  return count
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

-- Can craft item
function canCraft(name)
  if(craftingData[name]) then
    -- Find the recipe in data
    for _, req in ipairs(craftingData[name]) do
      local item, count = req[1], req[2]
      if countItem(item) < count then
        -- If can't craft it, that means there is no crafting recipe for the item
        if not canCraft(item) then
          return false
        end
      end
    end
    -- Can build if nothing stopped the function
    return true
  end
  -- If the if didn't work, that means there is no crafting recipe for the item
  return false
end

-- Singleblock setup
function setupMachine(machine, tier)
  if(machine == "Compressor") then
    if(tier == "LV" or tier == "ULV") then
      f()
      sel(findItem("Dirt"))
      place()
      b()
      sel(findItem("Hopper"))
      place()
      u()
      f()
      sel(findItem("Basic Solar Panel"))
      place()
      b()
      sel(findItem("Basic Compressor"))
      place()
      tr()
      f()
      tl()
      sel(findItem("Hopper"))
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
    sel(findItem("Vajra"))
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
    sel(findItem(material))
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
    swapTo(9, 1)
    swapTo(10, 1)
    sel(findItem("Stick"))
    swapTo(7, 1)
  end
  if(name == "Wrench") then
    sel(findItem(material))
    swapTo(1, 1)
    swapTo(3, 1)
    swapTo(5, 1)
    swapTo(6, 1)
    swapTo(7, 1)
    swapTo(10, 1)
    sel(findItem("Hammer"))
    swapTo(2, 1)
  end
  if(name == "2x2") then
    sel(findItem(material))
    swapTo(1, 1)
    swapTo(2, 1)
    swapTo(5, 1)
    swapTo(6, 1)
  end
  if(name == "1x1") then
    sel(findItem(material))
    swapTo(1, 1)
  end
  if(name == "1x2") then
    sel(findItem(material))
    swapTo(1, 1)
    swapTo(2, 1)
  end
end
function craft(nam, material, n)
  for i=1,n,1 do
    if(craftingData[nam]) then
      if(canCraft(nam)) then
        clearForCrafting()
        setUpCrafting(nam, material, 1)
        cr.craft(1)
      else
        for _, req in ipairs(craftingData[nam]) do
          local item, count = req[1], req[2]
          if countItem(item) < count then
            craft(item, nil, count - countItem(item))
          end
        end
      end
    else
      print("craft("+tostring(nam)+", "+tostring(material)+", "+tostring(n)+"): Death by lack of item")
    end
  end
end

-- Compressing
function compress(nam, n)
  setupMachine("Compressor", "ULV")
  for i=1,n,1 do
    if(nam == "Advanced Coke Oven Brick (Block)") then
      u()
      tr()
      f()
      tl()
      sel(findItem("Advanced Coke Oven Brick (Brick)"))
      robot.drop(4)
      tl()
      f()
      tr()
      d()
      -- TODO: softlock alert, moar failsafes
      while not robot.suck() do
      end
    end
  end
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
  sel(findItem("LV Energy Hatch"))
  place()
  tr()
  f()
  tl()
  place()
  tl()
  f()
  f()
  tr()
  sel(findItem("Heat Proof Machine Casing"))
  place()
  tl()
  f()
  tr()
  f()
  f()
  tr()
  sel(findItem("Maintenance Hatch"))
  place()
  tl()
  f()
  f()
  tr()
  f()
  tr()
  sel(findItem("Input Hatch (LV)"))
  place()
  tl()
  f()
  f()
  f()
  tr()
  f()
  f()
  tr()
  sel(findItem("Output Bus (LV)"))
  place()
  tr()
  f()
  tl()
  sel(findItem("Input Bus (LV)"))
  place()
  tr()
  f()
  tl()
  f()
  f()
  tl()
  f()
  sel(findItem("Heat Proof Machine Casing"))
  place()
  b()
  sel(findItem("Electric Blast Furnace"))
  place()
  
  sel(findItem("Cupronickel Coil Block"))
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
  sel(findItem("Heat Proof Machine Casing"))
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
  sel(findItem("Muffler Hatch (LV)"))
  placeD()
  sel(findItem("Wrench"))
  equip()
  robot.useDown(1)
  unequip()
  equip()
  b()
  d()
  tr()
  sel(findItem("Heat Proof Machine Casing"))
  place()
  ta()
  place()
  tr()
  b()
  sel(findItem("Output Hatch (LV)"))
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
  sel(findItem("BrainTech Aerospace Advanced Reinforced Duct Tape FAL-84"))
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
  sel(findItem("Coke Oven Brick (Block)"))
  square3()
  u()
  square3H()
  u()
  square3()
  d()
  d()
end
function buildAdvancedCokeOven()
  sel(findItem("Advanced Coke Oven Brick (Block)"))
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
    sel(findItem("Bronze Plated Bricks"))
  elseif(tier == 2) then
    sel(findItem("Solid Steel Machine Casing"))
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
  sel(findItem("Steam Grinder"))
  place()
  u()
  if(tier == 1) then
    sel(findItem("Bronze Plated Bricks"))
  elseif(tier == 2) then
    sel(findItem("Solid Steel Machine Casing"))
  end
  square3()
  d()
  d()
end
function buildSteamSquasher(tier)
  if(tier == 1) then
    sel(findItem("Bronze Plated Bricks"))
  elseif(tier == 2) then
    sel(findItem("Solid Steel Machine Casing"))
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
  sel(findItem("Steam Squasher"))
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
  if(not hasItem("Wrench")) then
    craft("Wrench", "Iron Ingot", 1)
  end
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
