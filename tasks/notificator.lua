rednet.close("left")
rednet.open("left")

rednet.host("notificator", "notificator")

local chatBox = peripheral.find("chatBox")

while true do
  local id, message, _ = rednet.receive()
  chatBox.sendMessage(message, id)
end
