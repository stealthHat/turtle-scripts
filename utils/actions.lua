local actions = {}

local block = require "utils.block"

local move_direction = {
  forward = turtle.forward,
  up = turtle.up,
  down = turtle.down,
  back = turtle.back,
}

local detect_direction = {
  forward = turtle.detect,
  up = turtle.detectUp,
  down = turtle.detectDown,
}

local dig_direction = {
  forward = turtle.dig,
  up = turtle.digUp,
  down = turtle.digDown,
}

function actions.move(direction)
  local tries = 10

  while not move_direction[direction]() do
    sleep(1)
    tries = tries - 1

    if tries == 0 then
      error("can't move " .. direction)
    end
  end

  return true
end

function actions.dig(direction)
  local tries = 10

  while detect_direction[direction]() do
    while not dig_direction[direction]() do
      sleep(1)
      tries = tries - 1

      if tries == 0 then
        error("can't dig " .. direction)
      end
    end
  end

  return true
end

function actions.refuel(min_fuel)
  if turtle.getFuelLevel() > min_fuel then
    return true
  end

  local item = turtle.getItemDetail(1)

  if item and string.find(block.fuel_blocks, item.name) then
    turtle.select(1)
    return turtle.refuel()
  end

  printError "no fuel to use"
  return false
end

function actions.drop_useless_blocks()
  for i = 1, 16 do
    local item = turtle.getItemDetail(i)

    if item and string.find(block.useless_blocks, item.name) then
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
