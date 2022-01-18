xInit, yInit, zInit = gps.locate(5)
xCoord, yCoord, zCoord = gps.locate(5)

directions = { "south", "west", "north", "east" }
direction, initDirection = nil
zDiff = {1, 0, -1, 0}
xDiff = {0, -1, 0, 1}

xProgress, yProgress, zProgress = nil
dProgress = nil

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

function detectDirection()
  turtle.up()
  local vec1 = vector.new(xInit, yInit, zInit)
  turtle.forward()
  local vec2 = vector.new(gps.locate(2, false))
  turtle.back()
  turtle.down()
  local resultVec = vec2 - vec1
  direction = (((resultVec.x + math.abs(resultVec.x) * 2) + (resultVec.z + math.abs(resultVec.z) * 3)) % 4) + 1
  initDirection= (((resultVec.x + math.abs(resultVec.x) * 2) + (resultVec.z + math.abs(resultVec.z) * 3)) % 4) + 1
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
    local success, data = turtle.inspectDown()
    if success and string.find(data.name, "turtle") then
      sleep(1)
    else
      turtle.digDown()
    end
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
      local success, data = turtle.inspectUp()
      if success and string.find(data.name, "turtle") then
        sleep(1)
      else
        turtle.digUp()
      end
    end
    while not turtle.up() do
      turtle.up()
    end
    yCoord = yCoord + 1
  end
end

function moveForward(mining)
  local mining = mining or false
  while turtle.detect() do
    local success, data = turtle.inspect()
    if success and string.find(data.name, "turtle") then
      sleep(1)
    else
      turtle.dig()
    end
  end
  while not turtle.forward() do
    turtle.forward()
  end
  if mining == true then
    turtle.digUp()
    turtle.digDown()
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

function backToWork(lane)
  moveUp((yInit - yCoord) + lane)
  goTo(xProgress, yProgress, zProgress)
  look(directions[dProgress])
end

function goHome(lane)
  dropUselessBlocks()
  xProgress, yProgress, zProgress = xCoord, yCoord, zCoord
  dProgress = direction
  moveUp((yInit - yCoord) + lane)
  goTo(xInit, yInit, zInit)
  look(directions[initDirection])
end

function dropItems()
  goHome(getLane())
  look("back")
  for num = 2,16 do
    turtle.select(num)
    turtle.drop()
  end
end

function noFuel()
  local curSlot = turtle.getSelectedSlot()
  local item = turtle.getItemDetail(1)
  if not item or item.name ~= "quark:charcoal_block" then
    print "Turtle has no Coal, backing to get some"
    turtle.select(1)
    turtle.drop()
    dropItems()
    look(directions[initDirection])
    turtle.select(1)
    turtle.suck()
    turtle.select(curSlot)
    backToWork(getLane())
  end
end

function inventoryFull()
  if turtle.getItemCount(16) > 0 then
    print "Inventory is full returning items"
    local curSlot = turtle.getSelectedSlot()
    dropItems()
    turtle.select(curSlot)
    backToWork(getLane())
  end
end

function getLane()
  return os.getComputerLabel():gsub("%D+", "") + 2
end
