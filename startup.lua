shell.run("rm", "*.lua")
shell.run("rm", "utils controllers tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/controllTurtles.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/startup.lua")
shell.run("mkdir", "utils controllers tasks")
shell.run("cd", "utils")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/utils/block.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/utils/locale.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/utils/actions.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/utils/mining.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/utils/quarry.lua")
shell.run("cd", "..")
shell.run("cd", "controllers")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/controllers/receive.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/controllers/send.lua")
shell.run("cd", "..")
shell.run("cd", "tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/new-structure/tasks/manager.lua")
shell.run("cd", "..")
shell.run "clear"

local locale = require "utils.locale"

if not locale.calibrate() then
  print "fail to calibrate"
end

local function readNumber()
  return tonumber(read())
end

print "location x , y , z"
local x,y, z = readNumber(), readNumber(), readNumber()

locale.go_to(x,y,z)
