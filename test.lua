local actions = require "utils.actions"

if actions.refuel() then
  print "yes"
else
  print "no"
end
