local locale = {}

local actions = require "utils.actions"

State = {
  coord = {
    x = 0,
    y = 0,
    z = 0,
    facing = string,
  },
  init_coord = {
    x = 0,
    y = 0,
    z = 0,
    facing = string,
  },
}

local bumps = {
  north = { 0, -1 },
  south = { 0, 1 },
  west = { -1, 0 },
  east = { 1, 0 },
}

local shift = {
  left = {
    north = "west",
    south = "east",
    east = "north",
    west = "south",
  },
  right = {
    north = "east",
    south = "west",
    east = "south",
    west = "north",
  },
}

function locale.calibrate()
  local sx, sy, sz = gps.locate(10, false)
  actions.move "forward"
  local nx, ny, nz = gps.locate(10, false)

  local facing = nx == sx + 1 and "east" or nx == sx - 1 and "west" or nz == sz + 1 and "south" or "north"

  State.init_coord = { x = sx, y = sy, z = sz, facing = facing }
  State.coord = { x = nx, y = ny, z = nz, facing = facing }
end

function locale.face(cardinal_direction)
  if cardinal_direction == State.coord.facing then
    return
  end

  if cardinal_direction == shift.right[State.coord.facing] then
    State.coord.facing = cardinal_direction
    return turtle.turnRight()
  end

  if cardinal_direction == shift.left[State.coord.facing] then
    State.coord.facing = cardinal_direction
    return turtle.turnLeft()
  end

  if cardinal_direction == shift.right[shift.right[State.coord.facing]] then
    State.coord.facing = cardinal_direction
    return turtle.turnRight() and turtle.turnRight()
  end
end

function locale.turn(side)
  if side == "left" then
    turtle.turnLeft()
    State.coord.facing = shift.left[State.coord.facing]
  elseif side == "right" then
    turtle.turnRight()
    State.coord.facing = shift.right[State.coord.facing]
  else
    turtle.turnRight()
    turtle.turnRight()
    State.coord.facing = shift.right[shift.right[State.coord.facing]]
  end
end

function locale.move(direction)
  local success = actions.move(direction)

  if success then
    local bump = bumps[State.coord.facing]

    if direction == "forward" then
      State.coord.x = State.coord.x + bump[1]
      State.coord.z = State.coord.z + bump[2]
    elseif direction == "up" then
      State.coord.y = State.coord.y + 1
    elseif direction == "down" then
      State.coord.y = State.coord.y - 1
    end
  end

  return success
end

function locale.has_enough_fuel(coord_a, coord_b)
  local cost = math.abs(coord_b.x - coord_a.x) + math.abs(coord_a.y - coord_b.y) + math.abs(coord_a.z - coord_b.z)

  if turtle.getFuelLevel() > cost then
    return true
  end

  return false
end

return locale
