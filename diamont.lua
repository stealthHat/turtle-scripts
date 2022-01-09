require "utils.mining"
require "utils.block"

usellesBlocks("Normal")
ore = "diamont"

moveDown(oreLevel(ore))

moveForward(50,true)

turtle.turnRight()
moveForward(1)
turtle.turnRight()

moveForward(50,true)

turtle.turnRight()
turtle.forward()
turtle.turnLeft()

moveForward(50,true)

turtle.turnLeft()
moveForward(1)
turtle.turnLeft()

moveForward(50,true)

moveDown(oreLevel(ore))
