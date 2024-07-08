local locale = {}

local actions = require "utils.actions"

State = {
  coord = nil,
  facing = nil,
  init_coord = nil,
  init_facing = nil,
  prog_coord = nil,
  prog_facing = nil,
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
  else
    turtle.turnRight()
    State.facing = right_shift[State.facing]
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

function locale.go_to(coord, func)
  if State.coord.x < coord.x then
    locale.face "east"

    while State.coord.x < coord.x do
      func "forward"
    end
  else
    locale.face "west"

    while State.coord.x > coord.x do
      func "forward"
    end
  end

  if State.coord.z < coord.z then
    locale.face "south"

    while State.coord.z < coord.z do
      func "forward"
    end
  else
    locale.face "north"

    while State.coord.z > coord.z do
      func "forward"
    end
  end

  while State.coord.y < coord.y do
    func "up"
  end

  while State.coord.y > coord.y do
    func "down"
  end
end

return locale
