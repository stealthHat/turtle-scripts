local locale = {}

locale["actions"] = require "utils.actions"

State = {
  location = {
    x = 0,
    y = 0,
    z = 0,
  },
  init_location = {
    x = 0,
    y = 0,
    z = 0,
  },
  init_orientation = "unknown",
  orientation = "unknown",
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
  local sx, sy, sz = gps.locate()

  turtle.forward()
  local nx, ny, nz = gps.locate()

  if nx == sx + 1 then
    State.orientation = "east"
  elseif nx == sx - 1 then
    State.orientation = "west"
  elseif nz == sz + 1 then
    State.orientation = "south"
  else
    State.orientation = "north"
  end

  State.location = { x = nx, y = ny, z = nz }
  State.init_location = { x = sx, y = sy, z = sz }
  State.init_orientation = State.orientation
  print("Calibrated to " .. State.location.x .. "," .. State.location.y .. "," .. State.location.z .. " facing " .. State.orientation)

  locale.move "back"

  return true
end

-- used on move
local function log_movement(direction)
  local bump

  if direction == "up" then
    State.location.y = State.location.y + 1
  elseif direction == "down" then
    State.location.y = State.location.y - 1
  elseif direction == "forward" then
    bump = bumps[State.orientation]
    State.location = { x = State.location.x + bump[1], y = State.location.y + bump[2], z = State.location.z + bump[3] }
  elseif direction == "back" then
    bump = bumps[State.orientation]
    State.location = { x = State.location.x - bump[1], y = State.location.y - bump[2], z = State.location.z - bump[3] }
  elseif direction == "left" then
    State.orientation = left_shift[State.orientation]
  elseif direction == "right" then
    State.orientation = right_shift[State.orientation]
  end

  return true
end

function locale.move(direction, nodig)
  locale.actions.move(direction, nodig)
  log_movement(direction)

  return true
end

function locale.face(orientation)
  if State.orientation == orientation then
    return true
  elseif right_shift[State.orientation] == orientation then
    if not locale.move "right" then
      return false
    end
  elseif left_shift[State.orientation] == orientation then
    if not locale.move "left" then
      return false
    end
  elseif right_shift[right_shift[State.orientation]] == orientation then
    if not locale.move "right" then
      return false
    end
    if not locale.move "right" then
      return false
    end
  else
    return false
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
