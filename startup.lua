shell.run("rm", "*.lua")
shell.run("rm", "utils tasks")
shell.run("mkdir", "utils tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/improvements/startup.lua")
shell.run("cd", "utils")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/improvements/utils/block.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/improvements/utils/locale.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/improvements/utils/actions.lua")
shell.run("cd", "..")
shell.run("cd", "tasks")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/improvements/tasks/quarry.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/improvements/tasks/galery.lua")
shell.run("wget", "https://raw.githubusercontent.com/stealthHat/turtle-scripts/improvements/tasks/manager.lua")
shell.run("cd", "..")
shell.run "clear"

local galery = require "tasks.galery"

print "Starting Galery"
galery.main()
