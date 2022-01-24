rednet.host("manager","manager")
jobAvailable = true

function readNumber()
  return tonumber(read())
end

print "xStart and zStart"
xStart, zStart = readNumber(), readNumber()
print "xEnd and zEnd"
xEnd, zEnd = readNumber(), readNumber()
print "yStart"
yNextJob = readNumber()
print "Quarry width"
qDist = readNumber()
print "Quarry depth"
qDepth = readNumber()

xNextJob = xStart
zNextJob = zStart

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
