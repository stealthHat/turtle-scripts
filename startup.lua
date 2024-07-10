shell.run("rm", "*.lua")
shell.run("rm", "utils tasks")
shell.run("mkdir", "utils tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/temp/quarry.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/temp/startup.lua")
shell.run("cd", "utils")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/temp/utils/block.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/temp/utils/locale.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/temp/utils/actions.lua")
shell.run("cd", "..")
shell.run("cd", "tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/temp/tasks/manager.lua")
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
