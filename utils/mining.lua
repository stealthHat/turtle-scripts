xInit, yInit, zInit = gps.locate(5)
xCoord, yCoord, zCoord = gps.locate(5)

directions = { "north", "east", "south", "west" }
zDiff = {-1, 0, 1, 0}
xDiff = {0, 1, 0, -1}

xProgress, yProgress, zProgress = null
dProgress = null

function dropUselessBlocks()
  local curSlot = turtle.getSelectedSlot()
  for slot = 1,16 do
    local item = turtle.getItemDetail(slot)
    if item and string.find(curUsellesBlocks , item.name) then
      turtle.select(slot)
      turtle.drop()
    end
  end
  turtle.select(curSlot)
end

function refuel()
  local curSlot = turtle.getSelectedSlot()
  if turtle.getFuelLevel() < 5000 then
    turtle.select(1)
    turtle.refuel()
    turtle.select(curSlot)
    print ("turtle refuled, current fuel level is: " .. turtle.getFuelLevel())
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

function moveDown()
  refuel()
  while turtle.detectDown() do
    turtle.digDown()
  end
  while not turtle.down() do
    turtle.down()
  end
  yCoord = yCoord - 1
end

function moveUp(x)
  for num = 1,x do
    refuel()
    while turtle.detectUp() do
      turtle.digUp()
    end
    while not turtle.up() do
      turtle.up()
    end
    yCoord = yCoord + 1
  end
end

function moveForward(mining)
  local mining = mining or false
  refuel()
  dropUselessBlocks()
  while turtle.detect() do
    turtle.dig()
  end
  if mining == true then
    turtle.digUp()
    turtle.digDown()
  end
  while not turtle.forward() do
    turtle.forward()
  end
  xCoord = xCoord + xDiff[direction]
  zCoord = zCoord + zDiff[direction]
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

function backToWork()
  moveUp((yInit - yCoord) + 10)
  goTo(xProgress, yProgress, zProgress)
  look(directions[dProgress])
end

function dropItems()
  xProgress, yProgress, zProgress = gps.locate(5)
  dProgress = direction
  moveUp((yInit - yCoord) + 10)
  goTo(xInit, yInit, zInit)
  look(directions[initDirection])
  tLeft()
  for num = 2,16 do
    turtle.select(num)
    turtle.drop()
  end
end

function noFuel()
  local curSlot = turtle.getSelectedSlot()
  local item = turtle.getItemDetail(1)
  if item and item.name ~= "quark:charcoal_block" then
    print "Turtle has no Coal, backing to get some"
    turtle.select(1)
    turtle.drop()
    dropItems()
    look(directions[initDirection])
    tRight()
    turtle.select(1)
    turtle.suck()
    turtle.select(curSlot)
    backToWork()
  end
end

function inventoryFull()
  if turtle.getItemCount(16) > 0 then
    print "Inventory is full returning items"
    local curSlot = turtle.getSelectedSlot()
    dropItems()
    turtle.select(curSlot)
    backToWork()
  end
end
