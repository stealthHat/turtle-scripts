local locale = {}

locale.state = {}
locale["actions"] = require "utils.actions"

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
    locale.state.orientation = "east"
  elseif nx == sx - 1 then
    locale.state.orientation = "west"
  elseif nz == sz + 1 then
    locale.state.orientation = "south"
  else
    locale.state.orientation = "north"
  end

  locale.state.location = { x = nx, y = ny, z = nz }
  locale.state.init_location = { x = sx, y = sy, z = sz }
  locale.state.init_orientation = locale.state.orientation
  print("Calibrated to " .. locale.state.location.x .. "," .. locale.state.location.y .. "," .. locale.state.location.z .. " facing " .. locale.state.orientation)

  locale.move "back"

  return true
end

-- used on move
local function log_movement(direction)
  local bump

  if direction == "up" then
    locale.state.location.y = locale.state.location.y + 1
  elseif direction == "down" then
    locale.state.location.y = locale.state.location.y - 1
  elseif direction == "forward" then
    bump = bumps[locale.state.orientation]
    locale.state.location = { x = locale.state.location.x + bump[1], y = locale.state.location.y + bump[2], z = locale.state.location.z + bump[3] }
  elseif direction == "back" then
    bump = bumps[locale.state.orientation]
    locale.state.location = { x = locale.state.location.x - bump[1], y = locale.state.location.y - bump[2], z = locale.state.location.z - bump[3] }
  elseif direction == "left" then
    locale.state.orientation = left_shift[locale.state.orientation]
  elseif direction == "right" then
    locale.state.orientation = right_shift[locale.state.orientation]
  end

  return true
end

function locale.move(direction, nodig)
  locale.actions.move(direction, nodig)
  log_movement(direction)

  return true
end

function locale.face(orientation)
  if locale.state.orientation == orientation then
    return true
  elseif right_shift[locale.state.orientation] == orientation then
    if not locale.move "right" then
      return false
    end
  elseif left_shift[locale.state.orientation] == orientation then
    if not locale.move "left" then
      return false
    end
  elseif right_shift[right_shift[locale.state.orientation]] == orientation then
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
  if location.x < locale.state.location.x then
    locale.face "west"
    while location.x < locale.state.location.x do
      locale.move "forward"
    end
  end
  if location.x > locale.state.location.x then
    locale.face "east"
    while location.x > locale.state.location.x do
      locale.move "forward"
    end
  end
  if location.z < locale.state.location.z then
    locale.face "north"
    while location.z < locale.state.location.z do
      locale.move "forward"
    end
  end
  if location.z > locale.state.location.z then
    locale.face "south"
    while location.z > locale.state.location.z do
      locale.move "forward"
    end
  end
  while location.y < locale.state.location.y do
    locale.move "down"
  end
  while location.y > locale.state.location.y do
    locale.move "up"
  end
end

return locale
