shell.run("rm", "*.lua")
shell.run("rm", "utils tasks")
shell.run("mkdir", "utils tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/quarry.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/galery.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/startup.lua")
shell.run("cd", "utils")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/utils/block.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/utils/locale.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/utils/actions.lua")
shell.run("cd", "..")
shell.run("cd", "tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/tasks/manager.lua")
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
