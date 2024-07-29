package.path = package.path .. ";../../?.lua"

local locale = require "utils.locale"
local actions = require "utils.actions"

local work = true
local control_plane_name = os.getComputerLabel():gsub("%d", "")

local function dig_and_move(direction)
  if not locale.move(direction) then
    return actions.dig(direction), locale.move(direction)
  end

  return false, true
end

local function go_to(coord)
  for _ = 1, State.init_coord.y - State.coord.y do
    if not locale.move "up" then
      dig_and_move "up"
    end
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

  locale.face(coord.facing)
end

local function restock()
  while turtle.getFuelLevel() < turtle.getFuelLimit() do
    if not turtle.suckUp(64) then
      break
    end

    actions.refuel()
  end

  actions.drop_blocks "down"
end

local function dig_and_move_check(direction)
  local dug, moved = dig_and_move(direction)

  if not dug and not moved then
    return false
  end

  if dug then
    if actions.is_inventory_full() then
      actions.drop_useless_blocks()
    end

    if actions.is_inventory_full() then
      actions.stack_and_organize_items()
    end

    if actions.is_inventory_full() then
      local prog_coord = State.coord
      go_to(State.init_coord)
      actions.drop_blocks "down"
      go_to(prog_coord)
    end
  end

  if moved then
    if not locale.has_enough_fuel(State.coord, State.init_coord) then
      turtle.refuel()
    end

    if not locale.has_enough_fuel(State.coord, State.init_coord) then
      local prog_coord = State.coord
      actions.drop_useless_blocks()
      go_to(State.init_coord)
      actions.drop_blocks "down"
      restock()
      go_to(prog_coord)
    end
  end

  return true
end

local function dig_quarry(width)
  while dig_and_move_check "down" do
    for row = 1, width do
      for _ = 1, width - 1 do
        dig_and_move_check "forward"
      end

      if row < width then
        local turn_direction = (row % 2 == 1) and "right" or "left"
        locale.turn(turn_direction)
        dig_and_move_check "forward"
        locale.turn(turn_direction)
      end
    end

    locale.turn "back"
  end
end

local function get_job(control_plane)
  while work do
    print "Getting a job"

    rednet.send(control_plane, "get_job")
    local _, job, _ = rednet.receive()

    if job then
      go_to { x = job.x, y = State.init_coord.y, z = job.z, facing = "east" }

      while actions.move "down" do
      end

      dig_quarry(job.width)
    end

    go_to(State.init_coord)
    actions.drop_blocks "down"
    work = false
  end
end

rednet.close "right"
rednet.open "right"

restock()
locale.calibrate()
get_job(rednet.lookup(control_plane_name, control_plane_name))
