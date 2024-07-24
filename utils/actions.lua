local actions = {}

local block = require "utils.block"

local move_direction = {
  forward = turtle.forward,
  up = turtle.up,
  down = turtle.down,
  back = turtle.back,
}

local turn_direction = {
  right = turtle.turnRight,
  left = turtle.turnLeft,
}

local dig_direction = {
  forward = turtle.dig,
  up = turtle.digUp,
  down = turtle.digDown,
}

local inspect_direction = {
  forward = turtle.inspect,
  up = turtle.inspectUp,
  down = turtle.inspectDown,
}

local detect_direction = {
  forward = turtle.detect,
  up = turtle.detectUp,
  down = turtle.detectDown,
}

local drop_direction = {
  forward = turtle.drop,
  up = turtle.dropUp,
  down = turtle.dropDown,
}

function actions.move(direction)
  if not detect_direction[direction]() then
    return move_direction[direction]()
  end

  local _, data = inspect_direction[direction]()

  if block.turtle[data.name] then
    while detect_direction[direction] do
      sleep(0.5)
    end

    return move_direction[direction]()
  end

  return move_direction[direction]()
end

function actions.turn(direction)
  if direction == "back" then
    turtle.turnRight()
    turtle.turnRight()
    return true
  end

  return turn_direction[direction]()
end

function actions.dig(direction)
  local _, data = inspect_direction[direction]()

  if block.cant_dig[data.name] then
    return false
  end

  if block.falling_blocks[data.name] then
    while detect_direction[direction] do
      dig_direction[direction]()
    end
    return true
  end

  dig_direction[direction]()
  return true
end

function actions.is_inventory_full()
  for slot = 1, 16 do
    if turtle.getItemCount(slot) == 0 then
      return false
    end
  end

  return true
end

function actions.refuel()
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)

    if item and turtle.refuel(0) then
      turtle.select(slot)
      turtle.refuel()
    end
  end

  turtle.select(1)
end

function actions.drop_blocks(direction)
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)

    if item then
      turtle.select(slot)
      drop_direction[direction]()
    end
  end

  turtle.select(1)
end

function actions.drop_useless_blocks()
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)

    if item and block.useless_blocks[item.name] then
      turtle.select(slot)
      turtle.drop()
    end
  end

  turtle.select(1)
end

function actions.stack_and_organize_items()
  for slot = 1, 16 do
    local current_slot = turtle.getItemDetail(slot)
    if current_slot then
      for i = slot + 1, 16 do
        local compare_slot = turtle.getItemDetail(i)
        if compare_slot and current_slot.name == compare_slot.name then
          turtle.select(i)
          turtle.transferTo(slot)
        end
      end
    end
  end

  for slot = 1, 16 do
    if not turtle.getItemDetail(slot) then
      for i = slot + 1, 16 do
        if turtle.getItemDetail(i) then
          turtle.select(i)
          turtle.transferTo(slot)
          break
        end
      end
    end
  end

  turtle.select(1)
end

return actions
