rednet.close("back")
rednet.open("back")
while true do
   print "What to do?"
   input = read()
   rednet.broadcast(input)
   if input == "exit" then
      break
   end
end
