local actions = {}

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

local inspect = {
  forward = turtle.inspect,
  up = turtle.inspectUp,
  down = turtle.inspectDown,
}

function actions.move(direction, nodig)
  if direction == "right" or direction == "left" or direction == "back" then
    nodig = true
  end
  if not nodig then
    while detect[direction]() do
      local success, data = inspect[direction]()
      if success and string.find(data.name, "turtle") then
        sleep(1)
      else
        dig[direction]()
      end
    end
  end
  if not move[direction]() then
    return false
  end
  return true
end

return actions
