----- IMPORTS -----
local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting
require("misc")
require("inventoryManager")
require("crafting")
require("building")

----- VARIABLES -----
--Rotation:
--  Z
--  1
--4   2 X
--  3
posX = 0
posY = 0
posZ = 0
rotation = 1

----- BASIC MOVEMENT -----
function f()  -- Forward
  if robot.forward() then
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
end
function b()  -- Back
  if robot.back() then
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
end
function u()  -- Up
  if robot.up() then
    posY = posY + 1
  end
end
function d()  -- Down
  if robot.down() then
    posY = posY - 1
  end
end
function tr()  -- Turn Right
  robot.turnRight()
  rotation = (rotation % 4) + 1
end
function tl()  -- Turn Left
  robot.turnLeft()
  rotation = (rotation - 2) % 4 + 1
end
function ta()  -- Turn Around
  robot.turnAround()
  rotation = (rotation + 1) % 4 + 1
end
function face(dir)  -- Face a direction
  while rotation ~= dir do
    tr()
  end
end

----- SPECIAL MOVEMENT -----
-- Move forward on land
function fTerrestrial()
  -- Move up until can move forward
  while robot.detect() do
    if robot.detectUp() then  -- If hit a ceiling, mine through
      robot.swingUp()
    end
    u()
  end

  -- Move forward when all is clear
  f()

  -- Move down to find the lowest point to continue from
  while not robot.detectDown() do
    d()
  end
end

----- SECTOR MOVEMENT -----
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

----- ORIGIN -----
-- Return to the 0,0,0 position (origin)
--First matches y, then x, then z
function origin()
  unselect()
  equip()
  selectItem("Vajra")
  equip()

  -- Avoid the chest by not mining straight through it
  --This is only an issue when coming from above to below
  if (posX == 0) and (posZ == 0) and (posY > 0) then
    f()
  end
  
  -- Y -> 0
  while posY > 0 do
    if robot.detectDown() then
      robot.swingDown()
    end
    d()
  end
  while posY < 0 do
    if robot.detectUp() then
      robot.swingUp()
    end
    u()
  end
  
  -- Face towards X+
  face(2)
  
  -- X -> 0 (negative)
  while posX < 0 do
    if robot.detect() then
      robot.swing()
    end
    f()
  end
  
  -- Face towards X-
  ta()
  
  -- X -> 0 (positive)
  while posX > 0 do
    if robot.detect() then
      robot.swing()
    end
    f()
  end
  
  -- Face towards Z+
  tr()
  
  -- X -> 0 (negative)
  while posZ < 0 do
    if robot.detect() then
      robot.swing()
    end
    f()
  end
  
  -- Face towards Z-
  ta()
  
  -- X -> 0 (positive)
  while posZ > 0 do
    if robot.detect() then
      robot.swing()
    end
    f()
  end
end

----- MINING -----
-- Mine down until cannot
function mineUntilBlock()
  unselect()
  equip()
  selectItem("Vajra")
  equip()
  while true do
    if not robot.swingDown() then
      if robot.detectDown() then
        break
      end
    end
    d()
  end
end

----- FINDING -----
-- Find block in world
--Cobblestone is used as a filler block
function findBlock(blockName, amount)
  amount = amount or 1
  unselect()
  equip()
  selectItem("Vajra")
  equip()
  while true do
    for i = 1,5 do  -- Only do checks every 5 blocks, saves on time
      if amount == 1 then  -- If only need one block, use hasItem
        if hasItem(blockName) then
          break
        end
      else  -- If need more than one, use countItem (note that this is much slower)
        if countItem(blockName) > amount then
          break
        end
      end
      selectFiller()
  
      if lastFillerSlot then  -- Does the robot have an active filler
        if not robot.compareDown() then
          -- If the block isn't a filler, get it and put down the filler
          robot.swingDown()
          robot.placeDown()
        end
        -- Otherwise do nothing and leave the filler where it is
      else
        -- Get whatever block is there and leave the space empty
        -- However, this will make the robot go down and up uselessly later
        robot.swingDown()
      end
  
      fTerrestrial()
    end
  end
end
