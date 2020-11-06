local component = require("component")
local modem = component.modem

local PORT = 42
local CMD = "drone_update_bios"

local function loadNewBios(path)
  return io.open(path):read("*a")
end

do
  print("Waking drones...")
  modem.broadcast(PORT, "wake_drone")
  os.sleep(10)
  print("Loading new BIOS...")
  local fullCmd = string.format("%s %s", CMD, loadNewBios("drone_bios.lua"))
  print("Broadcasting update...")
  modem.broadcast(PORT, fullCmd)
  print("Done")
end