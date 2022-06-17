require "mining"

manager = rednet.lookup("manager","manager")
jobAvailable = true

function checkForward()
  inventoryFull()
  moveForward(true)
end

function digLayer(area, depth)
  for num = 1,area do
    for i = 1, (area - 1) do
      checkForward()
    end
    if (num%2) == 1 and num < area then
      tLeft()
      checkForward()
      tLeft()
    elseif num < area then
      tRight()
      checkForward()
      tRight()
    end
  end
  turtle.digUp()
  turtle.digDown()
  refuel()
  goTo(xTo, Ycoord, zTo)
  look(directions[initdirection])
  for d = 1,3 do
    if Ycoord > depth then
      moveDown()
    end
  end
end

function digQuarry(xQuarry, yQuarry, zQuarry, area, depth)
  xTo, yTo, zTo = xQuarry, yQuarry, zQuarry, depth
  print("Going to " ..xTo.. " " ..yTo.. " " ..zTo)
  goTo(xTo, yTo, zTo)
  look(directions[initdirection])
  while Ycoord > depth do
    digLayer(area, depth)
  end
  print "Quarry done, getting another job"
  moveUp((yTo - Ycoord) + getLane())
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
      goHome((Yinit - Ycoord) + getLane())
    end
  end
end

local init = fs.open("init", "w")
init.write(tostring(Xinit).." "..tostring(Yinit).." "..tostring(Zinit))
init.close()

refuel()
detectdirection()
moveUp(getLane())
getJob()
fs.delete("init")
