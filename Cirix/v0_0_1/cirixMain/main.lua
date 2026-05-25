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
  selectItem("Cobblestone")
  place()
  u()
  place()
  d()
  selectItem("Gold Chest")
  placeU()
  equipSafe("Vajra")
  swing()
  f()
  swingU()
  b()
  
  findBlock("Sand", 52)
  print("Finding sand complete")
  origin()
  print("Returned to origin")
  unloadAllNonToolU()
  print("Unloaded all")
  lastFillerSlot = nil
  
  findBlock("Clay", 52)
  print("Finding clay complete")
  origin()
  print("Returned to origin")
  
  unloadAllNonToolU()
  print("Unloaded all")
  loadAllU()
  print("Loaded all")
  
  equipSafe("Vajra")
  robot.swingUp()
  print("Removed chest")
  
  alloySmelt("Coke Oven Brick (Brick)", 104)
  print("Alloy smelting complete")

  selectItem("Cobblestone")
  place()
  u()
  place()
  d()
  selectItem("Gold Chest")
  placeU()
  equipSafe("Vajra")
  swing()
  f()
  swingU()
  b()
  print("Placed chest back")
  
  craft("Coke Oven Brick (Block)", "Coke Oven Brick (Brick)", 26)
  print("Blocks have been crafted")

  unloadAllNonToolU()
  print("Unloaded all")
  loadAllU()
  print("Loaded all")

  equipSafe("Vajra")
  robot.swingUp()
  print("Removed chest")

  buildCokeOven()
  print("done")
end
