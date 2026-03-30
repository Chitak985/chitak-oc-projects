local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting

-- Shortened common functions
function f()robot.forward()end
function b()robot.back()end
function u()robot.up()end
function d()robot.down()end
function tr()robot.turnRight()end
function tl()robot.turnLeft()end
function ta()robot.turnAround()end
function getSlot(n)return ic.getStackInInternalSlot(n)end
function inv()return robot.inventorySize()end
function swap(n)robot.transferTo(n)end
function sel(n)robot.select(n)end
function place()robot.place()end
function placeU()robot.placeUp()end
function placeD()robot.placeDown()end
function equip()ic.equip()end

----- HELPER FUNCTIONS -----
-- Find item
function findItem(targetName)
  for slot = 1, inv() do
    local stack = getSlot(slot)
    if stack and stack.label == targetName then
      return slot
    end
  end
  return nil
end

-- Select empty
function unequip()
  for slot = 1,inv(),1 do
    if getSlot(slot) == nil then
      sel(slot)
      break
    end
  end
end

-- Crafting
function clearForCrafting()
  for slot = 1,12,1
  do
    if(getSlot(slot)) then
      sel(slot)
      for i = 14,inv() do
        if(getSlot(i) == nil) then
          swap(i)
          break
        end
      end
    end
  end
end
function setUpCrafting(name, material)
  if(name == "Hammer") then
    sel(findItem(material))
    swap(1, 1)
    swap(2, 1)
    swap(5, 1)
    swap(6, 1)
    swap(9, 1)
    swap(10, 1)
    sel(findItem("Stick"))
    swap(7, 1)
  end
  if(name == "Wrench") then
    sel(findItem(material))
    swap(1, 1)
    swap(3, 1)
    swap(5, 1)
    swap(7, 1)
    swap(10, 1)
    sel(findItem("Hammer"))
    swap(2, 1)
  end
end
function craft(nam, material, n)
  for i=1,n,1 do
    setUpCrafting(nam, material, 1)
    cr.craft(1)
  end
end

-- Multis
function buildEBF()
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
