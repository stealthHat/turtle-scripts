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

function actions.move(direction)
  return move_direction[direction]()
end

function actions.dig(direction)
  if not detect_direction[direction]() then
    return true
  end

  local _, data = inspect_direction[direction]()

  if block.cant_dig[data.name] then
    return false
  end

  if block.do_not_dig[data.name] then
    while detect_direction[direction] do
      sleep(0.5)
    end
    return true
  end

  if block.falling_blocks[data.name] then
    while detect_direction[direction] do
      dig_direction[direction]()
    end
    return true
  end

  return dig_direction[direction]()
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

function actions.drop_blocks()
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)

    if item then
      turtle.select(slot)
      turtle.drop()
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
