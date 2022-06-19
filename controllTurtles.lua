rednet.close "back"
rednet.open "back"

multishell.launch({}, "/tasks/manager.lua")
multishell.setTitle(2, "manager")

while true do
   print "What to do?"
   local input = read()
   rednet.broadcast(input)
   if input == "exit" then
      break
   end
end
