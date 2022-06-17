local state = {
  location = {
    x = nil,
    y = nil,
    z = nil,
  },
  orientation = nil,
}

state.location.x, state.location.y, state.location.z = gps.locate(5)
Xinit, Yinit, Zinit = gps.locate(5)
Xcoord, Ycoord, Zcoord = gps.locate(5)

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

local move = {
  forward = turtle.forward,
  up = turtle.up,
  down = turtle.down,
  back = turtle.back,
  left = turtle.turnLeft,
  right = turtle.turnRight,
}

local dig = {
  forward = turtle.dig,
  up = turtle.digUp,
  down = turtle.digDown,
}

local detect = {
  forward = turtle.detect,
  up = turtle.detectUp,
  down = turtle.detectDown,
}

function calibrate()
  -- GEOPOSITION BY MOVING TO ADJACENT BLOCK AND BACK
  local sx, sy, sz = gps.locate()
  if not sx or not sy or not sz then
    return false
  end
  for i = 1, 4 do
    -- TRY TO FIND EMPTY ADJACENT BLOCK
    if not turtle.detect() then
      break
    end
    if not turtle.turnRight() then
      return false
    end
  end
  if turtle.detect() then
    -- TRY TO DIG ADJACENT BLOCK
    for i = 1, 4 do
      dig.forward()
      if not turtle.detect() then
        break
      end
      if not turtle.turnRight() then
        return false
      end
    end
    if turtle.detect() then
      return false
    end
  end
  if not turtle.forward() then
    return false
  end

  -- block found
  local nx, ny, nz = gps.locate()
  if nx == sx + 1 then
    state.orientation = "east"
  elseif nx == sx - 1 then
    state.orientation = "west"
  elseif nz == sz + 1 then
    state.orientation = "south"
  elseif nz == sz - 1 then
    state.orientation = "north"
  else
    return false
  end
  state.location = { x = nx, y = ny, z = nz }
  print("Calibrated to " .. str_xyz(state.location, state.orientation))

  go("back")
  back()

  return true
end

function face(orientation)
  if state.orientation == orientation then
    return true
  elseif right_shift[state.orientation] == orientation then
    if not go "right" then
      return false
    end
  elseif left_shift[state.orientation] == orientation then
    if not go "left" then
      return false
    end
  elseif right_shift[right_shift[state.orientation]] == orientation then
    if not go "right" then
      return false
    end
    if not go "right" then
      return false
    end
  else
    return false
  end
  return true
end

function log_movement(direction)
  local bump
  if direction == "up" then
    state.location.y = state.location.y + 1
  elseif direction == "down" then
    state.location.y = state.location.y - 1
  elseif direction == "forward" then
    bump = bumps[state.orientation]
    state.location = { x = state.location.x + bump[1], y = state.location.y + bump[2], z = state.location.z + bump[3] }
  elseif direction == "back" then
    bump = bumps[state.orientation]
    state.location = { x = state.location.x - bump[1], y = state.location.y - bump[2], z = state.location.z - bump[3] }
  elseif direction == "left" then
    state.orientation = left_shift[state.orientation]
  elseif direction == "right" then
    state.orientation = right_shift[state.orientation]
  end
  return true
end

function go(direction, nodig)
  if not nodig then
    if detect[direction] then
      if detect[direction]() then
        dig[direction]()
      end
    end
  end
  if not move[direction] then
    return false
  end
  log_movement(direction)
  return true
end

function goTo(xTarget, yTarget, zTarget)
  if xTarget < Xcoord then
    face "west"
    while xTarget < Xcoord do
      go "forward"
    end
  end
  if xTarget > Xcoord then
    face "east"
    while xTarget > Xcoord do
      go "forward"
    end
  end
  if zTarget < Zcoord then
    face "north"
    while zTarget < Zcoord do
      go "forward"
    end
  end
  if zTarget > Zcoord then
    face "south"
    while zTarget > Zcoord do
      go "forward"
    end
  end
  while yTarget < Ycoord do
    go "down"
  end
  while yTarget > Ycoord do
    go "up"
  end
end

function backToWork(lane)
  moveUp((Yinit - Ycoord) + lane)
  goTo(xProgress, yProgress, zProgress)
  look(Directions[dProgress])
end

function goHome(lane)
  xProgress, yProgress, zProgress = Xcoord, Ycoord, Zcoord
  dProgress = direction
  moveUp((Yinit - Ycoord) + lane)
  goTo(Xinit, Yinit, Zinit)
  look(Directions[Init_direction])
end

function getLane()
  return os.getComputerLabel():gsub("%D+", "") + 2
end

function str_xyz(coords, facing)
  if facing then
    return coords.x .. "," .. coords.y .. "," .. coords.z .. ":" .. facing
  else
    return coords.x .. "," .. coords.y .. "," .. coords.z
  end
end
