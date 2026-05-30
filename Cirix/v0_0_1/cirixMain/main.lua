-- wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/main.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/misc.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/inventoryManager.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/crafting.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/building.lua && wget https://raw.githubusercontent.com/Chitak985/chitak-oc-projects/refs/heads/main/Cirix/v0_0_1/mainCirix/movement.lua

----- IMPORTS -----
local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting
dofile("misc.lua")
dofile("inventoryManager.lua")
dofile("movement.lua")
dofile("crafting.lua")
dofile("building.lua")

----- HELPER FUNCTIONS -----
function createChest()
  equipSafe("Vajra")
  swing()
  swingU()
  selectItem("Cobblestone")
  place()
  u()
  swing()
  place()
  d()
  selectItem("Gold Chest")
  placeU()
  swing()
  f()
  swingU()
  b()
  print("Chest constructed")
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
  -- Create chest at origin (safely)
  createChest()

  -- Get initial sand and clay amounts
  local amountTmpS = countItem("Sand")
  local amountTmpC = countItem("Clay")

  -- Unload all to optimize inventory space
  unloadAllNonToolU()
  print("Unloaded all")

  -- Get sand if there isn't enough
  if amountTmpS < 52 then
    while true do
      findBlock("Sand")
      print("Finding sand complete")
      mineFallingDeposit("Sand")
      print("Deposit mining complete")
      origin()
      print("Returned to origin")
      
      amountTmpS = amountTmpS + countItem("Sand")
      if amountTmpS >= 52 then
        break
      else
        unloadAllNonToolU()
        print("Unloaded all")
      end
    end
  end
  -- Unload all to optimize space (sand isn't needed anymore)
  unloadAllNonToolU()
  print("Unloaded all")
  lastFillerSlot = nil

  -- Get clay if there isn't enough
  if amountTmpC < 52 then
    while true do
      findBlock("Clay")
      print("Finding clay complete")
      mineFallingDeposit("Clay")
      print("Deposit mining complete")
      origin()
      print("Returned to origin")
      
      amountTmpC = amountTmpC + countItem("Clay")
      if amountTmpC >= 52 then
        break
      else
        unloadAllNonToolU()
        print("Unloaded all")
      end
    end
  end
  -- Unload all
  unloadAllNonToolU()
  print("Unloaded all")

  -- Load all (only really need clay and sand)
  loadAllU()
  print("Loaded all")
  
  -- Remove the chest to make space for machine setups
  equipSafe("Vajra")
  robot.swingUp()
  print("Removed chest")
  
  -- Make coke oven bricks
  alloySmelt("Coke Oven Brick (Brick)", 104)
  print("Alloy smelting complete")

  -- Add the chest back and sort inventory
  createChest()
  unloadAllNonToolU()
  print("Unloaded all")
  loadAllU()
  print("Loaded all")
  
  -- Craft coke oven blocks
  craft("Coke Oven Brick (Block)", "Coke Oven Brick (Brick)", 26)
  print("Blocks have been crafted")

  -- Sort inventory using existing chest
  unloadAllNonToolU()
  print("Unloaded all")
  loadAllU()
  print("Loaded all")

  -- Remove the chest to make space for coke oven
  equipSafe("Vajra")
  robot.swingUp()
  print("Removed chest")

  -- Build the coke oven
  buildCokeOven()
  print("done")
end
