require "utils.mining"
require "utils.block"

manager = 0;
jobAvailable = true

function digLayer(area, depth)
  for num = 1,area do
    for i = 1, (area - 1) do
      moveForward(true)
      inventoryFull()
    end
    if (num%2) == 1 and num < area then
      tLeft()
      moveForward(true)
      inventoryFull()
      tLeft()
    elseif num < area then
      tRight()
      moveForward(true)
      inventoryFull()
      tRight()
    end
  end
  turtle.digUp()
  turtle.digDown()
  refuel()
  noFuel()
  dropUselessBlocks()
  goTo(xTo, yCoord, zTo)
  look(directions[initDirection])
  for d = 1,3 do
    if yCoord > depth then
      moveDown()
    end
  end
end

function digQuarry(xQuarry, yQuarry, zQuarry, area, depth)
  xTo, yTo, zTo = xQuarry, yQuarry, zQuarry, depth
  print(yTo)
  print("Going to " ..xTo.. " " ..yTo.. " " ..zTo)
  goTo(xTo, yTo, zTo)
  look(directions[initDirection])
  while yCoord > depth do
    digLayer(area, depth)
  end
  print "Quarry done, getting another job"
  moveUp((yTo - yCoord) + getLane())
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
      id, qDepth, protocol = rednet.receive()
      print("Job available at " ..xQuarry.. " " ..zQuarry)
      digQuarry(tonumber(xQuarry), tonumber(yQuarry), tonumber(zQuarry), tonumber(qDist), tonumber(qDepth))
      print("Quarry done")
    elseif message == "no" then
      print("No more jobs, going home")
      jobAvailable = false
      goHome((yInit - yCoord) + getLane())
    end
  end
end

rednet.close("right")
rednet.open("right")

refuel()
usellesBlocks("Normal")
detectDirection()
moveUp(getLane())
getJob()
