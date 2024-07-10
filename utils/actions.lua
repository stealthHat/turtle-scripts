local actions = {}

local block = require "utils.block"

local move_direction = {
  forward = turtle.forward,
  up = turtle.up,
  down = turtle.down,
  back = turtle.back,
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

  while not dig_direction[direction]() do
    sleep(1)
    tries = tries - 1

    if tries == 0 then
      error("can't dig " .. direction)
    end
  end

  return true
end

function actions.refuel(min_fuel)
  if turtle.getFuelLevel() > min_fuel then
    return true
  end

  local item = turtle.getItemDetail(1)

  if item and block.fuel_blocks[item.name] then
    turtle.select(1)
    return turtle.refuel()
  end

  printError "no fuel to use"
  return false
end

function actions.drop_useless_blocks()
  for i = 1, 16 do
    local item = turtle.getItemDetail(i)

    if item and block.useless_blocks[item.name] then
      turtle.select(i)
      turtle.drop()
    end
  end

  turtle.select(1)
end

function actions.stack_and_organize_items()
  for i = 1, 16 do
    local current_slot = turtle.getItemDetail(i)
    if current_slot then
      for j = i + 1, 16 do
        local compare_slot = turtle.getItemDetail(j)
        if compare_slot and current_slot.name == compare_slot.name then
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

  turtle.select(1)
end

return actions
