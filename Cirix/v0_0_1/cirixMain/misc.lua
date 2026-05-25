----- IMPORTS -----
local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting

----- VARIABLES -----
lastFillerSlot = nil  -- Slot of the last filler block (cobblestone)

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
itemMap = {
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
multiblocks = {
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
craftingData = {
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

----- HELPER FUNCTIONS -----
-- Select empty
function unselect()
  for slot = 1,inv(),1 do
    if getSlot(slot) == nil then
      sel(slot)
      break
    end
  end
  -- TODO: Failsafe if no slots left
end

-- Safe equip (bypasses if something is already equipped)
function equipSafe(item)
  unselect()
  equip()
  selectItem(item)
  equip()
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
