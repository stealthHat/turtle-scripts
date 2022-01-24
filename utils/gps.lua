xInit, yInit, zInit = gps.locate(5)
xCoord, yCoord, zCoord = gps.locate(5)

directions = { "south", "west", "north", "east" }
direction, initDirection = nil
zDiff = {1, 0, -1, 0}
xDiff = {0, -1, 0, 1}

xProgress, yProgress, zProgress = nil
dProgress = nil

function detectDirection()
  turtle.up()
  local vec1 = vector.new(xInit, yInit, zInit)
  turtle.forward()
  local vec2 = vector.new(gps.locate(5))
  turtle.back()
  turtle.down()
  local resultVec = vec2 - vec1
  direction = (((resultVec.x + math.abs(resultVec.x) * 2) + (resultVec.z + math.abs(resultVec.z) * 3)) % 4) + 1
  initDirection= (((resultVec.x + math.abs(resultVec.x) * 2) + (resultVec.z + math.abs(resultVec.z) * 3)) % 4) + 1
end

function updateCoord(path)
  if path == "forward" then
    xCoord = xCoord + xDiff[direction]
    zCoord = zCoord + zDiff[direction]
  elseif path == "up" then
    yCoord = yCoord + 1
  else
    yCoord = yCoord - 1
  end
end

function updateDirection(turn)
  direction = direction - 1
  if turn == "left" then
    direction = (direction - 1 ) % 4
  elseif turn == "right" then
    direction = (direction + 1 ) % 4
  end
  direction = direction + 1
end

function look(turn)
  if turn == "back" then
    while direction ~= initDirection do
      tRight()
    end
    tRight()
    tRight()
  else
    while turn ~= directions[direction] do
      tRight()
    end
  end
end

function tLeft()
  updateDirection("left")
  turtle.turnLeft()
end

function tRight()
  updateDirection("right")
  turtle.turnRight()
end

function goTo(xTarget, yTarget, zTarget)
  if xTarget < xCoord then
    look("west")
    while xTarget < xCoord do
      moveForward()
    end
  end
  if xTarget > xCoord then
    look("east")
    while xTarget > xCoord do
      moveForward()
    end
  end
  if zTarget < zCoord then
    look("north")
    while zTarget < zCoord do
      moveForward()
    end
  end
  if zTarget > zCoord then
    look("south")
    while zTarget > zCoord do
      moveForward()
    end
  end
  while yTarget < yCoord do
    moveDown()
  end
  while yTarget > yCoord do
    moveUp(1)
  end
end

function backToWork(lane)
  moveUp((yInit - yCoord) + lane)
  goTo(xProgress, yProgress, zProgress)
  look(directions[dProgress])
end

function goHome(lane)
  xProgress, yProgress, zProgress = xCoord, yCoord, zCoord
  dProgress = direction
  moveUp((yInit - yCoord) + lane)
  goTo(xInit, yInit, zInit)
  look(directions[initDirection])
end

function getLane()
  return os.getComputerLabel():gsub("%D+", "") + 2
end
