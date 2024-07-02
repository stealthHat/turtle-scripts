local locale = {}

State = {}

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

function locale.face(side)
  local current_orientation = State.side

  if current_orientation == side then
    return true
  end

  if right_shift[State.facing] == side then
    State.facing = side
    return turtle.turnRight()
  end

  if left_shift[State.facing] == side then
    State.facing = side
    return turtle.turnLeft()
  end

  if right_shift[right_shift[State.facing]] == side then
    State.facing = side
    return turtle.turnRight() and turtle.turnRight()
  end

  return true
end

function locale.update_coord(direction)
  local bump

  if direction == "forward" then
    bump = bumps[State.facing]
    State.coord = { x = State.coord.x + bump[1], y = State.coord.y + bump[2], z = State.coord.z + bump[3] }
    return true
  end

  if direction == "back" then
    bump = bumps[State.facing]
    State.coord = { x = State.coord.x - bump[1], y = State.coord.y - bump[2], z = State.coord.z - bump[3] }
    return true
  end

  if direction == "up" then
    State.coord.y = State.coord.y + 1
    return true
  end

  if direction == "down" then
    State.coord.y = State.coord.y - 1
    return true
  end

  return false
end

function locale.go_to(coord)
  if coord.x < State.coord.x then
    locale.face "west"
    while coord.x < State.coord.x do
      locale.move "forward"
    end
  end
  if coord.x > State.coord.x then
    locale.face "east"
    while coord.x > State.coord.x do
      locale.move "forward"
    end
  end
  if coord.z < State.coord.z then
    locale.face "north"
    while coord.z < State.coord.z do
      locale.move "forward"
    end
  end
  if coord.z > State.coord.z then
    locale.face "south"
    while coord.z > State.coord.z do
      locale.move "forward"
    end
  end
  while coord.y < State.coord.y do
    locale.move "down"
  end
  while coord.y > State.coord.y do
    locale.move "up"
  end
end

return locale
