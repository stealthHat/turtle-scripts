package.path = package.path .. ";../../?.lua"

local locale = require "utils.locale"
local actions = require "utils.actions"
local block = require "utils.block"

local work = true

local detect_direction = {
  forward = turtle.detect,
  up = turtle.detectUp,
  down = turtle.detectDown,
}

local inspect_direction = {
  forward = turtle.inspect,
  up = turtle.inspectUp,
  down = turtle.inspectDown,
}

local function dig_and_move(direction)
  while detect_direction[direction]() do
    local success, data = inspect_direction[direction]()
    if success and not data.state["computercraft:turtle"] then
      actions.dig(direction)
    else
      sleep(1)
    end
  end

  locale.move(direction)
end

local function go_to(coord)
  if State.coord.x < coord.x then
    locale.face "east"

    while State.coord.x < coord.x do
      dig_and_move "forward"
    end
  else
    locale.face "west"

    while State.coord.x > coord.x do
      dig_and_move "forward"
    end
  end

  if State.coord.z < coord.z then
    locale.face "south"

    while State.coord.z < coord.z do
      dig_and_move "forward"
    end
  else
    locale.face "north"

    while State.coord.z > coord.z do
      dig_and_move "forward"
    end
  end

  while State.coord.y < coord.y do
    dig_and_move "up"
  end

  while State.coord.y > coord.y do
    dig_and_move "down"
  end
end

local function go_to_lane()
  local up = (State.init_coord.y - State.coord.y) + os.getComputerLabel():gsub("%D+", "")
  for _ = 1, up do
    dig_and_move "up"
  end
end

local function go_home()
  State.prog_coord = { x = State.coord.x, y = State.coord.y, z = State.coord.z }
  State.prog_facing = State.facing

  go_to_lane()

  go_to(State.init_coord)
  locale.face(State.init_facing)
end

local function back_to_work()
  go_to_lane()

  go_to(State.prog_coord)
  locale.face(State.prog_facing)
end

local function drop_items()
  go_home()

  locale.turn "right"

  local item = turtle.getItemDetail(1)

  if item and not block.fuel_blocks[item.name] then
    turtle.select(1)
    turtle.drop()
  end

  for slot = 2, 16 do
    turtle.select(slot)
    turtle.drop()
  end
end

local function inventory_check()
  if turtle.getItemCount(16) > 0 then
    actions.drop_useless_blocks()

    if turtle.getItemCount(16) > 0 then
      actions.stack_and_organize_items()
    end

    if turtle.getItemCount(16) > 0 then
      print "Inventory is full returning items"
      drop_items()
      back_to_work()
    end
  end
end

local function fuel_check()
  if not actions.refuel(5000) then
    print "Turtle has no Coal, backing to get some"
    drop_items()
    locale.face(State.init_facing)
    locale.turn "left"
    turtle.suck(64)
    back_to_work()
  end
end

local function dig_layer(width)
  for row = 1, width do
    for _ = 1, width - 1 do
      dig_and_move "forward"
      inventory_check()
      fuel_check()
    end

    if row < width then
      if row % 2 == 1 then
        locale.turn "left"
        dig_and_move "forward"
        locale.turn "left"
        inventory_check()
        fuel_check()
      else
        locale.turn "right"
        dig_and_move "forward"
        locale.turn "right"
        inventory_check()
        fuel_check()
      end
    end
  end
end

local function dig_quarry(x, y, z, width, depth)
  go_to { x = x, y = y, z = z }
  locale.face(State.init_facing)

  while depth < State.coord.y do
    dig_and_move "down"
    inventory_check()
    dig_layer(width)
    locale.turn "back"
  end

  print "Quarry done, getting another job"
  go_to_lane()
end

local function get_job(control_plane)
  while work do
    print "Requesting Job"
    rednet.send(control_plane, "get_job")

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

rednet.close "right"
rednet.open "right"

local control_plane_name = rednet.lookup("manager3", "manager3")

actions.refuel(5000)
locale.calibrate()
go_to_lane()
get_job(control_plane_name)
