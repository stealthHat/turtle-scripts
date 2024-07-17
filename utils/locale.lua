local locale = {}

local actions = require "utils.actions"

State = {
  coord = {},
  facing = string,
  init_coord = {},
  init_facing = string,
  prog_coord = {},
  prog_facing = string,
}

local bumps = {
  north = { 0, 0, -1 },
  south = { 0, 0, 1 },
  east = { 1, 0, 0 },
  west = { -1, 0, 0 },
}

local left_shift = {
  north = "west",
  south = "east",
  east = "north",
  west = "south",
}

local right_shift = {
  north = "east",
  south = "west",
  east = "south",
  west = "north",
}

function locale.calibrate()
  print "Stating calibration"

  local sx, sy, sz = gps.locate(10, false)
  turtle.forward()
  local nx, _, nz = gps.locate(10, false)
  turtle.back()

  if nx == sx + 1 then
    State.facing = "east"
  elseif nx == sx - 1 then
    State.facing = "west"
  elseif nz == sz + 1 then
    State.facing = "south"
  else
    State.facing = "north"
  end

  State.coord = { x = sx, y = sy, z = sz }
  State.init_coord = { x = sx, y = sy, z = sz }
  State.init_facing = State.facing

  print("Calibrated to " .. State.coord.x .. "," .. State.coord.y .. "," .. State.coord.z .. " facing " .. State.facing)
end

function locale.face(cardinal_direction)
  if cardinal_direction == State.facing then
    return
  end

  if cardinal_direction == right_shift[State.facing] then
    State.facing = cardinal_direction
    return turtle.turnRight()
  end

  if cardinal_direction == left_shift[State.facing] then
    State.facing = cardinal_direction
    return turtle.turnLeft()
  end

  if cardinal_direction == right_shift[right_shift[State.facing]] then
    State.facing = cardinal_direction
    return turtle.turnRight() and turtle.turnRight()
  end
end

function locale.turn(side)
  if side == "left" then
    turtle.turnLeft()
    State.facing = left_shift[State.facing]
  elseif side == "right" then
    turtle.turnRight()
    State.facing = right_shift[State.facing]
  else
    turtle.turnRight()
    turtle.turnRight()
    State.facing = right_shift[right_shift[State.facing]]
  end
end

function locale.move(direction)
  local bump

  if direction == "forward" then
    bump = bumps[State.facing]
    actions.move(direction)
    State.coord = { x = State.coord.x + bump[1], y = State.coord.y + bump[2], z = State.coord.z + bump[3] }
    return
  end

  if direction == "up" then
    actions.move(direction)
    State.coord.y = State.coord.y + 1
    return
  end

  if direction == "down" then
    actions.move(direction)
    State.coord.y = State.coord.y - 1
    return
  end

  if direction == "back" then
    bump = bumps[State.facing]
    actions.move(direction)
    State.coord = { x = State.coord.x - bump[1], y = State.coord.y - bump[2], z = State.coord.z - bump[3] }
    return
  end
end

function locale.calculate_fuel_cost(coord_a, coord_b)
  local cost = (math.abs(coord_b.x - coord_a.x) + math.abs(coord_a.y - coord_b.y) + math.abs(coord_a.z - coord_b.z)) * 2
  return cost
end

return locale
