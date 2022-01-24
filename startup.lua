shell.run("rm", "*.lua")
shell.run("rm", "utils controllers tasks")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/controllTurtles.lua")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/startup.lua")
shell.run("mkdir", "utils controllers tasks")
shell.run("cd", "utils")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/utils/block.lua")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/utils/gps.lua")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/utils/mining.lua")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/utils/quarry.lua")
shell.run("cd", "..")
shell.run("cd", "controllers")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/controllers/receive.lua")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/controllers/send.lua")
shell.run("cd", "..")
shell.run("cd", "tasks")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/startup/tasks/manager.lua")
shell.run("cd", "..")
shell.run("clear")

require "utils.gps"

if turtle then
  if fs.exists("init") then
    local file = fs.open("init", "r")
    xHome, yHome, zHome = file.readLine():match("(%S+)%s+(%S+)%s+(%S+)")
    xHome, yHome, zHome = tonumber(xHome), tonumber(yHome), tonumber(zHome)
    detectDirection()
    moveUp((yHome - yCoord) + lane)
    goTo(xHome, yHome, zHome)
    look(directions[initDirection])
    fs.delete("init")
  else
    shell.run("/controllers/receive.lua")
  end
end
