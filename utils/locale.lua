local locale = {}

locale["actions"] = require "utils.actions"

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
  local nx, ny, nz = gps.locate(10, false)
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

  State.location = { x = sx, y = sy, z = sz }
  State.init_location = { x = sx, y = sy, z = sz }
  State.init_facing = State.facing

  print("Calibrated to " .. State.location.x .. "," .. State.location.y .. "," .. State.location.z .. " facing " .. State.facing)
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

  if right_shift[right_shift[State.orientation]] == side then
    State.facing = side
    return turtle.turnRight() and turtle.turnRight()
  end

  return true
end

-- used on move
function locale.log_movement(direction)
  local bump

  if direction == "up" then
    State.location.y = State.location.y + 1
  elseif direction == "down" then
    State.location.y = State.location.y - 1
  elseif direction == "forward" then
    bump = bumps[State.facing]
    State.location = { x = State.location.x + bump[1], y = State.location.y + bump[2], z = State.location.z + bump[3] }
  elseif direction == "back" then
    bump = bumps[State.facing]
    State.location = { x = State.location.x - bump[1], y = State.location.y - bump[2], z = State.location.z - bump[3] }
  end

  return true
end

function locale.go_to(location)
  if location.x < State.location.x then
    locale.face "west"
    while location.x < State.location.x do
      locale.move "forward"
    end
  end
  if location.x > State.location.x then
    locale.face "east"
    while location.x > State.location.x do
      locale.move "forward"
    end
  end
  if location.z < State.location.z then
    locale.face "north"
    while location.z < State.location.z do
      locale.move "forward"
    end
  end
  if location.z > State.location.z then
    locale.face "south"
    while location.z > State.location.z do
      locale.move "forward"
    end
  end
  while location.y < State.location.y do
    locale.move "down"
  end
  while location.y > State.location.y do
    locale.move "up"
  end
end

return locale
