local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting

----- HELPER FUNCTIONS -----
-- Find item
function findItem(targetName)
  for slot = 1, robot.inventorySize() do
    local stack = ic.getStackInInternalSlot(slot)
    if stack and stack.label == targetName then
      return slot
    end
  end
  return nil
end

-- Select empty
function selectEmpty()
  for slot = 1,robot.inventorySize(),1 do
    if ic.getStackInInternalSlot(slot) == nil then
      robot.select(slot)
      break
    end
  end
end

-- Shortened common functions
function f()
  robot.forward()
end
function b()
  robot.back()
end
function u()
  robot.up()
end
function d()
  robot.down()
end
function tr()
  robot.turnRight()
end
function tl()
  robot.turnLeft()
end

-- Crafting
function clearForCrafting()
  for slot = 1,12,1 do
    if ic.getStackInInternalSlot(slot) then
      robot.select(slot)
      for i = 1,robot.inventorySize(),1 do
        if ic.getStackInInternalSlot(i) == nil then
          robot.transferTo(i)
          break
        end
      end
    end
  end
end
function setUpCrafting(nam, material, n)
  if(name == "Hammer") then
    robot.select(findItem(material))
    robot.transferTo(1, n)
    robot.transferTo(2, n)
    robot.transferTo(5, n)
    robot.transferTo(6, n)
    robot.transferTo(9, n)
    robot.transferTo(10, n)
    robot.select(findItem("Stick"))
    robot.transferTo(7, n)
  end
  if(name == "Wrench") then
    robot.select(findItem(material))
    robot.transferTo(1, n)
    robot.transferTo(3, n)
    robot.transferTo(5, n)
    robot.transferTo(7, n)
    robot.transferTo(10, n)
    robot.select(findItem("Hammer"))
    robot.transferTo(2, 1)
  end
end
function craft(nam, material, n)
  setUpCrafting(nam, material, n)
  cr.craft(n)
end

-- Multis
function buildEBF()
  f()
  f()
  f()
  f()
  tr()
  tr()
  robot.select(findItem("LV Energy Hatch"))
  robot.place()
  tr()
  f()
  tl()
  robot.place()
  tl()
  f()
  f()
  tr()
  robot.select(findItem("Heat Proof Machine Casing"))
  robot.place()
  tl()
  f()
  tr()
  f()
  f()
  tr()
  robot.select(findItem("Maintenance Hatch"))
  robot.place()
  tl()
  f()
  f()
  tr()
  f()
  tr()
  robot.select(findItem("Input Hatch (LV)"))
  robot.place()
  tl()
  f()
  f()
  f()
  tr()
  f()
  f()
  tr()
  robot.select(findItem("Output Bus (LV)"))
  robot.place()
  tr()
  f()
  tl()
  robot.select(findItem("Input Bus (LV)"))
  robot.place()
  tr()
  f()
  tl()
  f()
  f()
  tl()
  f()
  robot.select(findItem("Heat Proof Machine Casing"))
  robot.place()
  b()
  robot.select(findItem("Electric Blast Furnace"))
  robot.place()
  
  robot.select(findItem("Cupronickel Coil Block"))
  for i = 1,2,1 
  do
    u()
    f()
    f()
    f()
    tr()
    robot.place()
    tl()
    tl()
    robot.place()
    tr()
    b()
    robot.place()
    tr()
    robot.place()
    tl()
    tl()
    robot.place()
    tr()
    b()
    tr()
    robot.place()
    tl()
    tl()
    robot.place()
    tr()
    b()
    robot.place()
  end
  
  u()
  f()
  f()
  f()
  tr()
  robot.select(findItem("Heat Proof Machine Casing"))
  robot.place()
  tl()
  tl()
  robot.place()
  tr()
  b()
  robot.place()
  tr()
  robot.place()
  tl()
  tl()
  robot.place()
  tr()
  u()
  robot.select(findItem("Muffler Hatch (LV)"))
  robot.placeDown()
  robot.select(findItem("Wrench"))
  ic.equip()
  robot.useDown(1)
  selectEmpty()
  ic.equip()
  b()
  d()
  tr()
  robot.select(findItem("Heat Proof Machine Casing"))
  robot.place()
  tl()
  tl()
  robot.place()
  tr()
  b()
  robot.select(findItem("Output Hatch (LV)"))
  robot.place()
  
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
  robot.select(findItem("BrainTech Aerospace Advanced Reinforced Duct Tape FAL-84"))
  ic.equip()
  robot.use(2)
  selectEmpty()
  ic.equip()
  tl()
  f()
  f()
  tr()
  f()
  f()
  f()
  f()
  f()
  f()
  tr()
end

----- MAIN CODE -----
clearForCrafting()
craft("Hammer", "Iron Ingot", 1)
craft("Wrench", "Iron Ingot", 1)

buildEBF()
