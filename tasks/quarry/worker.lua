package.path = package.path .. ";../../?.lua"

local locale = require "utils.locale"
local actions = require "utils.actions"

local work = true
local control_plane_name = os.getComputerLabel():gsub("%d", "")

local function go_to(coord, face)
  for _ = 1, State.init_coord.y - State.coord.y do
    actions.dig "up"
    locale.move "up"
  end

  local x_diff = coord.x - State.coord.x
  if x_diff ~= 0 then
    locale.face(x_diff > 0 and "east" or "west")
    for _ = 1, math.abs(x_diff) do
      actions.dig "forward"
      locale.move "forward"
    end
  end

  local z_diff = coord.z - State.coord.z
  if z_diff ~= 0 then
    locale.face(z_diff > 0 and "south" or "north")
    for _ = 1, math.abs(z_diff) do
      actions.dig "forward"
      locale.move "forward"
    end
  end

  local y_diff = coord.y - State.coord.y
  if y_diff ~= 0 then
    local direction = y_diff > 0 and "up" or "down"
    for _ = 1, math.abs(y_diff) do
      actions.dig(direction)
      locale.move(direction)
    end
  end

  locale.face(face)
end

local function unload_and_restock(restock)
  local prog_coord = { State.coord, State.facing }

  actions.drop_useless_blocks()

  go_to(State.init_coord, State.init_facing)

  actions.drop_blocks "down"

  if restock then
    while turtle.getFuelLevel() < turtle.getFuelLimit() do
      if not turtle.suckUp(64) then
        break
      end

      actions.refuel()
    end
  end

  while not locale.has_enough_fuel(State.init_coord, prog_coord) do
    print "coal not enough"
    actions.refuel()
  end

  go_to(prog_coord)
end

local function dig_and_move(direction)
  if not actions.dig(direction) then
    return false
  end

  if actions.is_inventory_full() then
    actions.drop_useless_blocks()
  end

  if actions.is_inventory_full() then
    actions.stack_and_organize_items()
    actions.refuel()
  end

  if actions.is_inventory_full() then
    unload_and_restock(false)
  end

  if not locale.has_enough_fuel(State.coord, State.init_coord) then
    unload_and_restock(true)
  end

  return locale.move(direction)
end

local function dig_quarry(width)
  print "going to possition"
  while actions.move "down" do
  end

  while dig_and_move "down" do
    for row = 1, width do
      for _ = 1, width - 1 do
        dig_and_move "forward"
      end

      if row < width then
        local turn_direction = (row % 2 == 1) and "left" or "right"
        locale.turn(turn_direction)
        dig_and_move "forward"
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
      go_to({ x = job.x, y = State.init_coord.y, z = job.z }, State.init_facing)

      dig_quarry(job.width)
    end

    go_to(State.init_coord, State.init_facing)
    actions.drop_blocks "down"
    work = false
  end
end

rednet.close "right"
rednet.open "right"

actions.refuel()
locale.calibrate()
get_job(rednet.lookup(control_plane_name, control_plane_name))
