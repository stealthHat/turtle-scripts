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

function actions.move(direction, nodig)
  if string.find("left right back", direction) then
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

function actions.refuel()
  local curSlot = turtle.getSelectedSlot()
  local data = turtle.getItemDetail(1)

  if data and string.find(actions.fuel_blocks, data.name) then
    turtle.select(1)
    turtle.refuel()
    turtle.select(curSlot)
    print("turtle refiled, current fuel level is: " .. turtle.getFuelLevel())

    return true
  else
    print "No fuel to use"
    return false
  end
end

function actions.drop_useless_blocks()
  local curSlot = turtle.getSelectedSlot()

  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and string.find(actions.useless_blocks, item.name) then
      turtle.select(slot)
      turtle.drop()
    end
  end

  turtle.select(curSlot)
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

  turtle.select(1)
end

return actions
