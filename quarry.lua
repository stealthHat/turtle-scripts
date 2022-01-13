require "utils.mining"
require "utils.block"

manager = 0;
jobAvailable = true

xQuarry, yQuarry, zQuarry = null
direction, initDirection = 1, 1

usellesBlocks("Normal")

function digLayer(area)
  for num = 1,area do
    for i = 1, (area - 1) do
      noFuel()
      inventoryFull()
      moveForward(true)
    end
    if (num%2) == 1 and num < area then
      tLeft()
      moveForward(true)
      tLeft()
    elseif num < area then
      tRight()
      moveForward(true)
      tRight()
    end
  end
  turtle.digUp()
  turtle.digDown()
  goTo(xTo, yCoord, zTo)
  look(directions[initDirection])
  for d = 1,3 do
    if yCoord > 55 then
      moveDown()
    end
  end
end

function digQuarry(xQuarry, yQuarry, zQuarry, area, deepth)
  xTo, yTo, zTo = xQuarry, yQuarry, zQuarry
  print("Going to " ..xTo.. " " ..yTo.. " " ..zTo)
  goTo(xTo, yTo, zTo)
  look(directions[initDirection])
  while yCoord > 55 do
    digLayer(area)
  end
  print "Quarry done, going home"
  moveUp((yInit - yCoord) + 10)
end

function getJob()
  while jobAvailable do
    print("Requesting Job")
    rednet.send(manager, "getJob")
    id, message, protocol = rednet.receive()
    if message == "yes" then
      id, xQuarry, protocol = rednet.receive()
      id, yQuarry, protocol = rednet.receive()
      id, zQuarry, protocol = rednet.receive()
      id, qDist, protocol = rednet.receive()
      print("Job available at " ..xQuarry.. " " ..zQuarry)
      moveUp((yInit - yCoord) + 10)
      digQuarry(tonumber(xQuarry), tonumber(yQuarry), tonumber(zQuarry), tonumber(qDist), "test")
      print("Quarry done")
    elseif message == "no" then
      print("No more jobs, going home")
      goTo(xInit, yInit, zInit)
      jobAvailable = false
    end
  end
end

rednet.close("right")
rednet.open("right")

getJob()
