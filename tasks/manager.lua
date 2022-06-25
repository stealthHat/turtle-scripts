local manager = {}
local job = {}
local coords = {}

local function readNumber()
  return tonumber(read())
end

local function setNextJob()
  job.zNextJob = job.zNextJob - job.qDist
  if job.zNextJob < coords.zEnd then
    job.zNextJob = coords.z_start
    job.xNextJob = job.xNextJob - job.qDist
    if job.xNextJob < coords.xEnd then
      coords.jobAvailable = false
    end
  end
end

function manager.main()
  rednet.close "back"
  rednet.open "back"

  rednet.host("manager", "manager")

  coords.jobAvailable = true
  print "x_start and z_start"
  coords.x_start, coords.z_start = readNumber(), readNumber()
  print "xEnd and zEnd"
  coords.xEnd, coords.zEnd = readNumber(), readNumber()

  job.xNextJob = coords.x_start
  job.zNextJob = coords.z_start
  print "yStart"
  job.yNextJob = readNumber()
  print "yEnd"
  job.qDepth = readNumber()
  print "Quarry width"
  job.qDist = readNumber()


  while coords.jobAvailable do
    print "Waiting for turtles"
    local id, message, _ = rednet.receive()
    print("Tutle " .. id .. " needs a job")

    if message == "getJob" then
      print("Job available at " .. job.xNextJob .. " " .. job.zNextJob)
      rednet.send(id, "yes")
      rednet.send(id, table.concat(job, " "))
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
end

return manager
