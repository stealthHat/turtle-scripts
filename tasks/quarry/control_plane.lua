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
print "y_end"
local depth = read_number()
print "Quarry width"
local width = read_number()

local function make_jobs()
  local x_min = math.min(x_start, x_end)
  local x_max = math.max(x_start, x_end)
  local z_min = math.min(z_start, z_end)
  local z_max = math.max(z_start, z_end)

  for x = x_min, x_max, width do
    for z = z_min, z_max, width do
      local job = {
        x = x - width,
        y = y_start,
        z = z - width,
        width = width,
        depth = depth,
      }
      table.insert(job_queue, job)
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
