rednet.close("right")
rednet.open("right")
while true do
   senderID, message, distance = rednet.receive()
   if message == "quarry" then
     print "Starting quarry"
     shell.run("/utils/quarry.lua")
   end
end
