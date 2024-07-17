local job_queue = {}

local function read_number()
  return tonumber(read())
end

print "control plane name"
local control_plane_name = read()
print "x_start and z_start"
local x_start, z_start = read_number(), read_number()
print "x_end and z_end"
local x_end, z_end = read_number(), read_number()
print "Quarry width"
local width = read_number()

local function make_jobs()
  local x_min = math.min(x_start, x_end)
  local x_max = math.max(x_start, x_end) - width
  local z_min = math.min(z_start, z_end)
  local z_max = math.max(z_start, z_end) - width

  for x = x_min, x_max, width do
    for z = z_min, z_max, width do
      local job = {
        x = x,
        z = z,
        width = width,
      }
      table.insert(job_queue, job)
    end
  end
end

local function run_jobs()
  while #job_queue > 0 do
    print "Waiting for turtles"
    local id, message, _ = rednet.receive()
    print("Turtle " .. id .. " needs a job")

    if id and message == "get_job" then
      local job = table.remove(job_queue, 1)
      print("Assigning job at " .. job.x .. " " .. job.z)
      rednet.send(id, "yes")
      rednet.send(id, job)
    end
  end

  print "No Jobs available"

  while true do
    local id, message, _ = rednet.receive()
    if id and message == "get_job" then
      rednet.send(id, "no")
    end
  end
end

rednet.close "back"
rednet.open "back"

if control_plane_name then
  rednet.host(control_plane_name, control_plane_name)
end

make_jobs()
run_jobs()
