shell.run("rm", "diamont.lua")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/diamont.lua")
shell.run("rm", "quarry.lua")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/quarry.lua")
shell.run("rm", "utils")
shell.run("mkdir", "utils")
shell.run("cd", "utils")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/utils/mining.lua")
shell.run("wget","https://raw.githubusercontent.com/stealthHat/turtle-scripts/main/utils/block.lua")
shell.run("cd", "..")
