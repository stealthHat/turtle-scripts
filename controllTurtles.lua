rednet.close("back")
rednet.open("back")

multishell.launch({}, "/tasks/manager.lua")
multishell.launch({}, "/controllers/send.lua")
multishell.setTitle(2, "manager")
multishell.setTitle(3, "send")
