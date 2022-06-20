shell.run("rm", "*.lua")
shell.run("rm", "utils tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/controllTurtles.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/quarry.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/galery.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/startup.lua")
shell.run("mkdir", "utils controllers tasks")
shell.run("cd", "utils")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/utils/block.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/utils/locale.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/utils/actions.lua")
shell.run("cd", "..")
shell.run("cd", "tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/tasks/manager.lua")
shell.run("cd", "..")
shell.run "clear"

if turtle then
  rednet.close "right"
  rednet.open "right"

  while true do
    local _, message, _ = rednet.receive()
    if message == "quarry" then
      print "Starting quarry"
      shell.run "quarry.lua"
    end
  end
end
