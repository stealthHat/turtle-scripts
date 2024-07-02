local actions = {}

actions["useless_blocks"] = require("utils.block").useless_blocks
actions["fuel_blocks"] = require("utils.block").fuel_blocks

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

function actions.move(direction)
  local tries = 10

  if string.find(direction, "left right") then
    move[direction]()
    return true
  end

  while not move[direction]() do
    sleep(1)
    tries = tries - 1

    if tries == 0 then
      printError("can't move " .. direction)
      return false
    end
  end

  return true
end

function actions.refuel()
  local item = turtle.getItemDetail(1)

  if item and string.find(item.name, actions.fuel_blocks) then
    turtle.select(1)
    turtle.refuel()
    return true
  end

  printError "no fuel to use"
  return false
end

function actions.drop_useless_blocks()
  for i = 1, 16 do
    local item = turtle.getItemDetail(i)

    if item and string.find(item.name, actions.useless_blocks) then
      turtle.select(i)
      turtle.drop()
    end
  end
end

function actions.stack_and_organize_items()
  for i = 1, 16 do
    local currentSlot = turtle.getItemDetail(i)
    if currentSlot then
      for j = i + 1, 16 do
        local compareSlot = turtle.getItemDetail(j)
        if compareSlot and currentSlot.name == compareSlot.name then
          turtle.select(j)
          turtle.transferTo(i)
        end
      end
    end
  end

  for i = 1, 16 do
    if not turtle.getItemDetail(i) then
      for j = i + 1, 16 do
        if turtle.getItemDetail(j) then
          turtle.select(j)
          turtle.transferTo(i)
          break
        end
      end
    end
  end
end

return actions
