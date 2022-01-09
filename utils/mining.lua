xInit, yInit, zInit = gps.locate()
xProgress, yProgress, zProgress = gps.locate()
xCoord, yCoord, zCoord = gps.locate()
directions = { "north", "east", "south", "west" }
dProgress = 0

function saveProgress()
  xProgress, yProgress, zProgress = gps.locate()
  dProgress = direction
  moveUp((yInit - yCoord) + 10)
  goTo(xInit, yInit, zInit)
end

function hasCoal()
  local item = turtle.getItemDetail(1)
  if item and item.name ~= "quark:charcoal_block" then
    print "Turtle has no Coal, backing to get some"
    local curSlot = turtle.getSelectedSlot()
    saveProgress()
    look(directions[initDirection])
    tRight()
    tRight()
    for num = 1,16 do
      turtle.select(num)
      turtle.drop()
    end
    look(directions[initDirection])
    turtle.select(1)
    turtle.suck()
    turtle.select(curSlot)
    moveUp((yInit - yCoord) + 10)
    goTo(xProgress, yProgress, zProgress)
    look(directions[dProgress])
  end
end

function inventoryFull()
  if turtle.getItemCount(16) > 0 then
    print "Inventory is full returning items"
    local curSlot = turtle.getSelectedSlot()
    saveProgress()
    look(directions[initDirection])
    tRight()
    tRight()
    for num = 2,16 do
      turtle.select(num)
      turtle.drop()
    end
    turtle.select(curSlot)
    moveUp((yInit - yCoord) + 10)
    goTo(xProgress, yProgress, zProgress)
    look(directions[dProgress])
  end
end

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
  while turn ~= directions[direction] do
    tRight()
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

function moveDown(x)
  for num = 1,x do
    refuel()
    while turtle.detectDown() do
      print "Block underneath, diging and trying again ..."
      turtle.digDown()
    end
    while not turtle.down() do
      print "Could move down, trying again ..."
      turtle.down()
    end
    xCoord, yCoord, zCoord = gps.locate()
  end
end

function moveUp(x)
  for num = 1,x do
    refuel()
    while turtle.detectUp() do
      print "Block above, diging and trying again ..."
      turtle.digUp()
    end
    while not turtle.up() do
      print "Could move up, trying again ..."
      turtle.up()
    end
    xCoord, yCoord, zCoord = gps.locate()
  end
end

function moveForward(x,mining)
  mining = mining or false
  for num = 1,x do
    refuel()
    dropUselessBlocks()
    while turtle.detect() do
      print "Block ahead, diging and trying again ..."
      turtle.dig()
    end
    if mining == true then
      turtle.digUp()
      turtle.digDown()
    end
    while not turtle.forward() do
      print "Could move ahead, trying again ..."
      turtle.forward()
    end
    xCoord, yCoord, zCoord = gps.locate()
  end
end

function oreLevel(ore)
  if ore == "diamont" then
    return yCoord - -58
  elseif ore == "gold" then
    return yCoord - 32
  end
end

function goTo(xTarget, yTarget, zTarget)
  if xTarget < xCoord then
    look("west")
    while xTarget < xCoord do
      moveForward(1)
    end
  end
  if xTarget > xCoord then
    look("east")
    while xTarget > xCoord do
      moveForward(1)
    end
  end
  if zTarget < zCoord then
    look("north")
    while zTarget < zCoord do
      moveForward(1)
    end
  end
  if zTarget > zCoord then
    look("south")
    while zTarget > zCoord do
      moveForward(1)
    end
  end
  while yTarget < yCoord do
    moveDown(1)
  end
  while yTarget > yCoord do
    moveUp(1)
  end
end
