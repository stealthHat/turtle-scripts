local function send()
  while true do
    print "What to do?"
    local input = read()
    rednet.broadcast(input)
    if input == "exit" then
      break
    end
  end
end

rednet.close "back"
rednet.open "back"

multishell.launch({}, "/tasks/manager.lua")
multishell.launch({}, send())
multishell.setTitle(2, "manager")
multishell.setTitle(2, "send")
