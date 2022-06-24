local actions = require "utils.actions"

local function dig_galery(x)
  for _ = 1, x do
    turtle.digUp()
    turtle.digDown()
    actions.move "forward"
    actions.drop_useless_blocks()
  end
end

local function go_to_y(y, dir)
  for _ = 1, y do
    actions.move(dir)
    actions.drop_useless_blocks()
  end
end

print "dig down"
local ore = tonumber(read())

go_to_y(ore, "down")

dig_galery(50)

turtle.turnRight()
dig_galery(1)
turtle.turnRight()

dig_galery(50)

turtle.turnRight()
dig_galery(1)
turtle.turnLeft()

dig_galery(50)

turtle.turnLeft()
dig_galery(1)
turtle.turnLeft()

dig_galery(50)

go_to_y(ore, "up")
