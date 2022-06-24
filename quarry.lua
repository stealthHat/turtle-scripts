local locale = require "utils.locale"

local manager = rednet.lookup("manager", "manager")
local jobAvailable = true

local function go_home(lane)
  State.prog_location = { x = State.location.x, y = State.location.y, z = State.location.z }
  State.prog_orientation = State.orientation

  Go_to_lane(lane)

  locale.go_to(State.init_location)
  locale.face(State.init_orientation)
end

local function back_to_work()
  Go_to_lane(Get_lane())

  locale.go_to(State.prog_location)
  locale.face(State.prog_orientation)
end

function Get_lane()
  return os.getComputerLabel():gsub("%D+", "") + 2
end

function Go_to_lane(lane)
  local up = (State.init_location.y - State.location.y) + lane
  for _ = 1, up do
    locale.move "up"
  end
end

local function drop_items()
  go_home(Get_lane())
  locale.move "right"
  for num = 2, 16 do
    turtle.select(num)
    turtle.drop()
  end
  turtle.select(1)
  locale.face(State.init_orientation)
end

local function refuel()
  if turtle.getFuelLevel() > 5000 then
  elseif not locale.actions.refuel() then
    print "Turtle has no Coal, backing to get some"
    turtle.select(1)
    turtle.drop()
    drop_items()
    locale.move "left"
    turtle.select(1)
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

local function check_forward()
  inventory_full()
  refuel()
  turtle.digUp()
  turtle.digDown()
  locale.move "forward"
end

local function dig_layer(x, z, area, depth)
  for num = 1, area do
    for _ = 1, (area - 1) do
      check_forward()
    end
    if (num % 2) == 1 and num < area then
      locale.move "left"
      check_forward()
      locale.move "left"
    elseif num < area then
      locale.move "right"
      check_forward()
      locale.move "right"
    end
  end

  turtle.digUp()
  turtle.digDown()
  local position = { x = x, y = State.location.y, z = z }
  locale.go_to(position)
  locale.face(State.init_orientation)

  for _ = 1, 3 do
    if State.location.y > depth then
      locale.move "down"
    end
  end
end

local function dig_quarry(x, y, z, area, depth)
  local position = { x = x, y = y, z = z }
  locale.go_to(position)
  locale.face(State.init_orientation)

  while State.location.y > depth do
    dig_layer(x, z, area, depth)
  end

  print "Quarry done, getting another job"
  Go_to_lane(Get_lane())
end

local function get_job()
  while jobAvailable do
    print "Requesting Job"
    rednet.send(manager, "getJob")
    local _, message, _ = rednet.receive()
    if message == "yes" then
      local _, x, _ = rednet.receive()
      local _, y, _ = rednet.receive()
      local _, z, _ = rednet.receive()
      local _, q_dist, _ = rednet.receive()
      local _, q_depth, _ = rednet.receive()
      print("Job available at " .. x .. " " .. z)
      dig_quarry(tonumber(x), tonumber(y), tonumber(z), tonumber(q_dist), tonumber(q_depth))
      print "Quarry done"
    elseif message == "no" then
      print "No more jobs, going home"
      jobAvailable = false
      go_home(Get_lane())
    end
  end
end

refuel()
locale.calibrate()
Go_to_lane(Get_lane())
get_job()
