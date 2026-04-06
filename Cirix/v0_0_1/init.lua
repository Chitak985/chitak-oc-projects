-- init.lua file for the Cirix Submind, not the actual Cirix itself, use main.lua instead.
do
  local addr, invoke = computer.getBootAddress(), component.invoke
  local function loadfile(file)
    local handle = assert(invoke(addr, "open", file))
    local buffer = ""
    repeat
      local data = invoke(addr, "read", handle, math.maxinteger or math.huge)
      buffer = buffer .. (data or "")
    until not data
    invoke(addr, "close", handle)
    return load(buffer, "=" .. file, "bt", _G)
  end
  loadfile("/lib/core/boot.lua")(loadfile)
end

local component = require("component")
local robot = component.robot
robot.turnAround()
robot.turnAround()
robot.turnAround()
robot.turnAround()
robot.turnAround()
