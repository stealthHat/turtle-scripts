package.path = package.path .. ";../../?.lua"

local locale = require "utils.locale"
local actions = require "utils.actions"

local work = true
local lane = os.getComputerLabel():gsub("%D+", "")
local control_plane_name = os.getComputerLabel():gsub("%d", "")

local inspect_direction = {
  forward = turtle.inspect,
  up = turtle.inspectUp,
  down = turtle.inspectDown,
}

local detect_direction = {
  forward = turtle.detect,
  up = turtle.detectUp,
  down = turtle.detectDown,
}

local function go_to(coord)
  local function dig_and_move(direction)
    while detect_direction[direction]() do
      local _, data = inspect_direction[direction]()
      if not string.find(data.name, "turtle") then
        actions.dig(direction)
      end
      sleep(0.5)
    end

    locale.move(direction)
  end

  local up = (State.init_coord.y - State.coord.y) + lane
  for _ = 1, up do
    dig_and_move "up"
  end

  local x_diff = coord.x - State.coord.x
  if x_diff ~= 0 then
    locale.face(x_diff > 0 and "east" or "west")
    for _ = 1, math.abs(x_diff) do
      dig_and_move "forward"
    end
  end

  local z_diff = coord.z - State.coord.z
  if z_diff ~= 0 then
    locale.face(z_diff > 0 and "south" or "north")
    for _ = 1, math.abs(z_diff) do
      dig_and_move "forward"
    end
  end

  local y_diff = coord.y - State.coord.y
  if y_diff ~= 0 then
    local direction = y_diff > 0 and "up" or "down"
    for _ = 1, math.abs(y_diff) do
      dig_and_move(direction)
    end
  end
end

local function go_home()
  State.prog_coord = { x = State.coord.x, y = State.coord.y, z = State.coord.z }
  State.prog_facing = State.facing

  go_to(State.init_coord)
  locale.face(State.init_facing)
end

local function go_work()
  go_to(State.prog_coord)
  locale.face(State.prog_facing)
end

local function fuel_check()
  if turtle.getFuelLevel() <= locale.calculate_fuel_cost(State.coord, State.init_coord) then
    actions.refuel()
    if turtle.getFuelLevel() <= locale.calculate_fuel_cost(State.coord, State.init_coord) then
      go_home()

      locale.turn "left"
      while turtle.getFuelLevel() < turtle.getFuelLimit() do
        local success = turtle.suck(64)

        if success then
          actions.refuel()
        end

        break
      end

      locale.turn "back"
      actions.drop_blocks()

      go_work()
    end
  end
end

local function inventory_check()
  if actions.is_inventory_full() then
    actions.drop_useless_blocks()

    if actions.is_inventory_full() then
      actions.stack_and_organize_items()
    end

    if actions.is_inventory_full() then
      go_home()

      locale.turn "right"
      actions.drop_blocks()

      go_work()
    end
  end
end

local function dig_and_check(direction)
  actions.dig(direction)
  inventory_check()
end

local function dig_quarry(x, z, width)
  local function move_down_three_times()
    for _ = 1, 3 do
      if not dig_and_check "down" then
        return false
      end
    end
    locale.move "down"
    return true
  end

  local function dig_layer()
    dig_and_check "up"
    dig_and_check "down"

    while detect_direction["forward"]() do
      dig_and_check "forward"
    end

    locale.move "forward"
    fuel_check()
  end

  local function move_to_start_position()
    while not detect_direction["down"]() do
      locale.move "down"
    end
  end

  move_to_start_position()

  local y = (State.init_coord.y - State.coord.y) + lane
  go_to { x = x, y = y, z = z }
  locale.face(State.init_facing)

  while move_down_three_times() do
    for row = 1, width do
      for _ = 1, width - 1 do
        dig_layer()
      end

      if row < width then
        local turn_direction = (row % 2 == 1) and "left" or "right"
        locale.turn(turn_direction)
        dig_layer()
        locale.turn(turn_direction)
      end
    end

    locale.turn "back"
  end
end

local function get_job(control_plane)
  while work do
    rednet.send(control_plane, "get_job")

    local _, message, _ = rednet.receive()
    if message == "yes" then
      local _, job, _ = rednet.receive()

      if job then
        dig_quarry(job.x, job.z, job.width)
      end
    elseif message == "no" then
      work = false
      go_home()
      locale.turn "right"
      actions.drop_blocks()
      locale.face(State.init_facing)
    end
  end
end

rednet.close "right"
rednet.open "right"

actions.refuel()
locale.calibrate()
get_job(rednet.lookup(control_plane_name, control_plane_name))
