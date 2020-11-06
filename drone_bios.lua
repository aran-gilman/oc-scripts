local drone = component.proxy(component.list("drone")())
local modem = component.proxy(component.list("modem")())

local function updateBios(newBios)
  drone.setStatusText("Updating")
  drone.setLightColor(0xFF00FF)
  local eeprom = component.proxy(component.list("eeprom")())
  eeprom.set(newBios)
  computer.shutdown()
end

local function recharge(range)
  drone.setLightColor(0xFF0000)
  drone.setStatusText("Recharge")
  for _, w in ipairs(component.proxy(component.list("navigation")()).findWaypoints(range)) do
    if w.label == "ChargeStation" then
      local pos = w.position
      drone.move(pos[1], pos[2], pos[3])
      while computer.energy() < 5000 do os.sleep(5) end
      return
    end
  end
end

local function parse(msg)
  local cmd = string.match(msg, "%g+")
  local args = string.sub(msg, string.len(cmd)+2)
  if cmd == "drone_shutdown" then computer.shutdown()
  elseif cmd == "drone_update_bios" then updateBios(args)
  elseif cmd == "drone_recharge" then recharge(100) end
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
    local evt, _, _, _, _, msg = computer.pullSignal(10)
    if evt == "modem_message" then
      drone.setLightColor(0xFFFF00)
      parse(msg)
    end
    if computer.energy() < 500 then recharge(100) end
  end
end