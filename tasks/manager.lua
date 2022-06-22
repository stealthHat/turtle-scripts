rednet.close("back")
rednet.open("back")

rednet.host("manager", "manager")

local jobAvailable = true

local function readNumber()
  return tonumber(read())
end

print "xStart and zStart"
local xStart, zStart = 2246, -1087 --readNumber(), readNumber()
print "xEnd and zEnd"
local xEnd, zEnd = 2186,-1149 --readNumber(), readNumber()
print "yStart"
local yNextJob = 63 --readNumber()
print "yEnd"
local qDepth = 5 --readNumber()
print "Quarry width"
local qDist = readNumber()

local xNextJob = xStart
local zNextJob = zStart

local function setNextJob()
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
  print "Waiting for turtles"
  local id, message, _ = rednet.receive()
  print("Tutle " .. id .. " needs a job")

  if message == "getJob" then
    print("Job available at " .. xNextJob .. " " .. zNextJob)
    rednet.send(id, "yes")
    rednet.send(id, tostring(xNextJob))
    rednet.send(id, tostring(yNextJob))
    rednet.send(id, tostring(zNextJob))
    rednet.send(id, tostring(qDist))
    rednet.send(id, tostring(qDepth))
    setNextJob()
  end
end

print "No Jobs available"

while true do
  local id, message, _ = rednet.receive()
  if message == "getJob" then
    rednet.send(id, "no")
  end
end
