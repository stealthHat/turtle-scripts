local locale = require "utils.locale"
local actions = require "utils.actions"
local movements = require "utils.movements"

local manager = rednet.lookup("manager", "manager")
local lane = os.getComputerLabel():gsub("%D+", "")
local work = true

local function go_to_lane()
  local up = (State.init_coord.y - State.location.y) + lane
  for _ = 1, up do
    actions.move "up"
  end
end

local function go_home()
  State.prog_coord = { x = State.coord.x, y = State.coord.y, z = State.coord.z }
  State.prog_facing = State.facing

  go_to_lane()
  movements.go_to(State.init_location)
  locale.face(State.init_orientation)
end

local function back_to_work()
  go_to_lane()

  locale.go_to(State.prog_coord)
  locale.face(State.prog_facing)
end

local function drop_items()
  go_home()

  actions.move "right"

  local item = turtle.getItemDetail(1)

  if item and not string.find(locale.actions.fuel_blocks, item.name) then
    turtle.select(1)
    turtle.drop()
  end

  for slot = 2, 16 do
    turtle.select(slot)
    turtle.drop()
  end

  locale.face(State.init_facing)
end

local function health_check()
  if ! actions.refuel() then
    print "Turtle has no Coal, backing to get some"
    drop_items()
    locale.move "left"
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

local function mineLayer(x, z, width)
  for row = 1, width do
    for col = 1, width - 1 do
      digAndMoveForward()
    end

    if row < width then
      if row % 2 == 1 then
        turtle.turnRight()
        digAndMoveForward()
        turtle.turnRight()
      else
        turtle.turnLeft()
        digAndMoveForward()
        turtle.turnLeft()
      end
    end
  end
end

local function dig_layer(x, z, width, depth)
  for row = 1, width do
    for _ = 1, (width - 1) do
      health_check()
      actions.dig "forward"
      actions.dig "up"
      actions.dig "down"
    end
    if (row % 2) == 1 and row < width then
      locale.move "left"
      health_check()
      locale.move "left"
    elseif row < width then
      locale.move "right"
      health_check()
      locale.move "right"
    end
  end

  health_check()
  actions.dig "forward"
  actions.dig "up"
  actions.dig "down"
  local position = { x = x, y = State.location.y, z = z }
  locale.go_to(position)
  locale.face(State.init_orientation)
  health_check()

  for _ = 1, 3 do
    if State.location.y > depth then
      health_check()
      locale.move "down"
    end
  end
end

local function dig_quarry(x, y, z, width, depth)
  local position = { x = x, y = y, z = z }
  locale.go_to(position)
  locale.face(State.init_orientation)

  while State.location.y > depth do
    dig_layer(x, z, width, depth)
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
      work = false
      go_home()
    end
  end
end

actions.refuel()
locale.calibrate()
go_to_lane()
get_job()
