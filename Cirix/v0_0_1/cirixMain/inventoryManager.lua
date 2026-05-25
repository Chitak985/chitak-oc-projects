----- IMPORTS -----
local component = require("component")
local robot = require("robot")
local ic = component.inventory_controller
local cr = component.crafting

----- INVENTORY -----
-- Find an item in the inventory
function findItem(name)
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

-- Count the number of items
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

-- True/False if has item
function hasItem(name)
  return findItem(name) ~= nil
end

-- Select an item "safely"
function selectItem(name)
  local slot = findItem(name)
  if not slot then
    print("selectItem("..tostring(name).."): Item not found: "..tostring(name))
    return nil
  end
  return sel(slot)
end

----- FILLER LOGIC -----
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

----- ITEM UNLOADING -----
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

----- ITEM LOADING -----
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
