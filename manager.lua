jobAvailable = true

xStart, zStart = 100, 150
xEnd, zEnd = 200, 10000
qDist = 5
qDepth = 13

xNextJob = xStart
zNextJob = zStart
yNextJob = 31

rednet.close("back")
rednet.open("back")

function setNextJob()
  zNextJob = zNextJob - qDist
  if zNextJob < zEnd then
    zNextJob = zStart
    xNextJob = xNextJob - qDist
    if xNextJob < xEnd then
      jobAvailable = false
    end
  end
end

while jobAvailable do
  print("Waiting for turtles")
  id, message, protocolt = rednet.receive()
  print("Tutle " ..id.. " needs a job")

  if message == "getJob" then
    print("Job available at " ..xNextJob.. " " ..zNextJob)
    rednet.send(id, "yes")
    rednet.send(id, tostring(xNextJob))
    rednet.send(id, tostring(yNextJob))
    rednet.send(id, tostring(zNextJob))
    rednet.send(id, tostring(qDist))
    rednet.send(id, tostring(qDepth))
    setNextJob()
  end
end

print("No Jobs available")

while true do
  id, message, protocol = rednet.receive()
  if message == "getJob" then
    rednet.send(id, "no")
  end
end
