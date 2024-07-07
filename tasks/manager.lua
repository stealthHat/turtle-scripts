rednet.close "back"
rednet.open "back"

rednet.host("manager", "manager")

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

for x = x_start, x_end, -width do
  for z = z_start, z_end, -width do
    local x_job = math.max(x, x_end + width - 1)
    local z_job = math.max(z, z_end + width - 1)
    table.insert(job_queue, { x = x_job, y = y_start, z = z_job, width = width, depth = depth })
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

while #job_queue > 0 do
  print "Waiting for turtles"
  local id, message, _ = rednet.receive()
  print("Turtle " .. id .. " needs a job")

  if message == "getJob" then
    local job = table.remove(job_queue)
    print("Assigning job at " .. job.x .. " " .. job.z)
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
