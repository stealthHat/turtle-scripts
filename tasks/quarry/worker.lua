local gps = require "../utils/gps"
local actions = require "../utils/actions"

local lane = os.getComputerLabel():gsub("%D+", "")
local work = true

local function go_to_lane()
  local up = (State.init_coord.y - State.coord.y) + lane
  for _ = 1, up do
    gps.move "up"
  end
end

local function go_home()
  State.prog_coord = { x = State.coord.x, y = State.coord.y, z = State.coord.z }
  State.prog_facing = State.facing

  go_to_lane()

  gps.go_to(State.init_coord)
  gps.face(State.init_facing)
end

local function back_to_work()
  go_to_lane()

  gps.go_to(State.prog_coord)
  gps.face(State.prog_facing)
end

local function drop_items()
  go_home()

  gps.turn "right"

  local item = turtle.getItemDetail(1)

  if item and not string.find(gps.actions.fuel_blocks, item.name) then
    turtle.select(1)
    turtle.drop()
  end

  for slot = 2, 16 do
    turtle.select(slot)
    turtle.drop()
  end
end

local function health_check()
  if not actions.refuel(5000) then
    print "Turtle has no Coal, backing to get some"
    drop_items()
    gps.face(State.init_facing)
    gps.turn "left"
    turtle.suck()
    back_to_work()
  end

  if turtle.getItemCount(15) > 0 then
    actions.drop_useless_blocks()

    if turtle.getItemCount(15) > 0 then
      actions.stack_and_organize_items()
    end

    if turtle.getItemCount(15) > 0 then
      print "Inventory is full returning items"
      drop_items()
      back_to_work()
    end
  end
end

local function health_and_act(func)
  func()
  health_check()
end

local function move_and_dig()
  health_and_act(actions.dig "forward")
  health_and_act(actions.move "forward")
  health_and_act(actions.dig "up")
  health_and_act(actions.dig "down")
end

local function dig_layer(width)
  for row = 1, width do
    for _ = 1, (width - 1) do
      move_and_dig()
    end

    if row < width and row % 2 == 1 then
      gps.turn "left"
      move_and_dig()
      gps.turn "left"
    elseif row < width then
      gps.turn "right"
      move_and_dig()
      gps.turn "right"
    end
  end
end

local function dig_quarry(x, y, z, width, depth)
  gps.go_to { x = x, y = y, z = z }
  gps.face(State.init_orientation)

  while depth < State.location.y do
    dig_layer(width)
    gps.go_to { x = x, y = State.coord.y, z = z }

    for _ = 1, 3 do
      if depth < State.location.y then
        health_and_act(actions.dig "down")
        health_and_act(actions.move "down")
      end
    end
  end

  print "Quarry done, getting another job"
  go_to_lane()
end

local function get_job()
  while work do
    print "Requesting Job"
    rednet.send(manager, "getJob")

    local _, message, _ = rednet.receive()

    if message == "yes" then
      local _, job_string, _ = rednet.receive()
      local chunk = load("return " .. job_string)

      if chunk then
        local job = chunk()
        print("Job available at " .. job.x .. " " .. job.z)

        dig_quarry(job.x, job.y, job.z, job.width, job.depth)

        print "Quarry done"
      end
    elseif message == "no" then
      print "No more jobs, going home"
      work = false
      go_home()
    end
  end
end

print "control plane name"
local control_plane_name = tostring(read())
local manager = rednet.lookup(control_plane_name, control_plane_name)

actions.refuel(5000)
gps.calibrate()
go_to_lane()
get_job()
