local job_queue = {}

local function read_number()
  return tonumber(read())
end

print "x_start and z_start"
local x_start, z_start = read_number(), read_number()
print "x_end and z_end"
local x_end, z_end = read_number(), read_number()
print "y_start"
local y_start = read_number()
print "yEnd"
local depth = read_number()
print "Quarry width"
local width = read_number()

local function make_jobs()
  local minX = math.min(x_start, x_end)
  local maxX = math.max(x_start, x_end)
  local minZ = math.min(z_start, z_end)
  local maxZ = math.max(z_start, z_end)

  for x = minX, maxX, width do
    for z = minZ, maxZ, width do
      if x + width - 1 <= maxX and z + width - 1 <= maxZ then
        local job = {
          x = x,
          y = y_start,
          z = z,
          width = width,
          depth = depth,
        }
        table.insert(job_queue, job)
      end
    end
  end
end

local function table_to_string(tbl)
  local str = "{ "
  for k, v in pairs(tbl) do
    str = str .. k .. " = " .. tostring(v) .. ", "
  end
  str = str:sub(1, -2) .. " }"
  return str
end

local function run_jobs()
  while #job_queue > 0 do
    print "Waiting for turtles"
    local id, message, _ = rednet.receive()
    print("Turtle " .. id .. " needs a job")

    if message == "get_job" then
      local job = table.remove(job_queue, 1)
      print("Assigning job at " .. job.x .. " " .. job.z)
      rednet.send(id, "yes")
      rednet.send(id, table_to_string(job))
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

rednet.close "back"
rednet.open "back"

rednet.host("manager3", "manager3")

make_jobs()
run_jobs()
