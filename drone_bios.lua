local drone = component.proxy(component.list("drone")())
local modem = component.proxy(component.list("modem")())

local function updateBios(newBios)
  drone.setStatusText("Updating")
  drone.setLightColor(0xFF00FF)
  local eeprom = component.proxy(component.list("eeprom")())
  eeprom.set(newBios)
  computer.shutdown()
end

local function parse(msg)
  local cmd = string.match(msg, "%g+")
  local args = string.sub(msg, string.len(cmd)+2)
  if cmd == "drone_shutdown" then computer.shutdown()
  elseif cmd == "drone_update_bios" then updateBios(args) end
end

do
  drone.setLightColor(0xFFFF00)
  modem.open(42)
  if modem.getWakeMessage() == nil then
    modem.setWakeMessage("wake_drone")
  end
  drone.setStatusText("Initialized")
  while true do
    drone.setLightColor(0x00FF00)
    local evt, _, _, _, _, msg = computer.pullSignal()
    if evt == "modem_message" then
      drone.setLightColor(0xFFFF00)
      parse(msg)
    end
  end
end