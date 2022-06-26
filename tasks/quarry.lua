local quarry = {}
local locale = require "utils.locale"

local manager = rednet.lookup("manager", "manager")
local jobAvailable = true

local function go_home(lane)
  locale.state.prog_location = { x = locale.state.location.x, y = locale.state.location.y, z = locale.state.location.z }
  locale.state.prog_orientation = locale.state.orientation

  quarry.go_to_lane(lane)

  locale.go_to(locale.state.init_location)
  locale.face(locale.state.init_orientation)
end

local function back_to_work()
  quarry.go_to_lane(quarry.get_lane())

  locale.go_to(locale.state.prog_location)
  locale.face(locale.state.prog_orientation)
end

local function drop_items()
  go_home(quarry.get_lane())
  locale.move "right"

  local data = turtle.getItemDetail(1)
  if data and not string.find(locale.actions.fuel_blocks, data.name) then
    turtle.select(1)
    turtle.drop()
  end
  for num = 2, 16 do
    turtle.select(num)
    turtle.drop()
  end

  turtle.select(1)
  locale.face(locale.state.init_orientation)
end

local function refuel()
  if turtle.getFuelLevel() > 5000 then
  elseif not locale.actions.refuel() then
    print "Turtle has no Coal, backing to get some"
    drop_items()
    locale.move "left"
    turtle.suck()
    back_to_work()
  end
end

local function inventory_full()
  if turtle.getItemCount(16) > 0 then
    locale.actions.drop_useless_blocks()
    if turtle.getItemCount(16) > 0 then
      print "Inventory is full returning items"
      drop_items()
      back_to_work()
    end
  end
end

local function move(direction)
  if direction == "forward" then
    inventory_full()
    refuel()
    turtle.digUp()
    turtle.digDown()
    locale.move "forward"
  elseif direction == "down" then
    if locale.state.location.y > quarry.depth then
      locale.move "down"
    end
  end
end

local function check_forward()
  inventory_full()
  refuel()
  turtle.digUp()
  turtle.digDown()
  locale.move "forward"
  turtle.digUp()
  turtle.digDown()
end

local function dig_layer(x, z, width)
  for num = 1, width do
    for _ = 1, (width - 1) do
      check_forward()
    end
    if (num % 2) == 1 and num < width then
      locale.move "left"
      check_forward()
      locale.move "left"
    elseif num < width then
      locale.move "right"
      check_forward()
      locale.move "right"
    end
  end

  local position = { x = x, y = locale.state.location.y, z = z }
  locale.go_to(position)
  locale.face(locale.state.init_orientation)

  for _ = 1, 3 do
    move "down"
  end
end

local function dig_quarry(job)
  local position = { x = quarry.job.x, y = quarry.job.y, z = quarry.job.z }
  local layer = { x = quarry.job.x, z = quarry.job.z, area = quarry.job.area }

  locale.go_to(position)
  locale.face(locale.state.init_orientation)

  while locale.state.location.y > job.depth do
    dig_layer(layer)
  end

  print "Quarry done, getting another job"
  quarry.go_to_lane(quarry.get_lane())
end

local function get_job()
  while jobAvailable do
    print "Requesting Job"
    rednet.send(manager, "getJob")
    local _, message, _ = rednet.receive()
    if message == "yes" then
      quarry.job = { x = rednet.receive(), z = rednet.receive(), y = rednet.receive(), q_dist = rednet.receive(), q_depth = rednet.receive() }
      tonumber(quarry.job)
      print("Job available at " .. quarry.job.x .. " " .. quarry.job.z)
      dig_quarry(quarry.job)
      print "Quarry done"
    elseif message == "no" then
      print "No more jobs, going home"
      jobAvailable = false
      go_home(quarry.get_lane())
    end
  end
end

function quarry.get_lane()
  return os.getComputerLabel():gsub("%D+", "") + 2
end

function quarry.go_to_lane(lane)
  local up = (locale.state.init_location.y - locale.state.location.y) + lane
  for _ = 1, up do
    locale.move "up"
  end
end

function quarry.main()
  refuel()
  locale.calibrate()
  quarry.go_to_lane(quarry.get_lane())
  get_job()
end
