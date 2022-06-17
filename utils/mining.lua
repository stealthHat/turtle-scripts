require "gps"
require "block"

function refuel()
  local curSlot = turtle.getSelectedSlot()
  if turtle.getFuelLevel() < 5000 then
    if not item or not string.find(item.name,"charcoal coal coke") then
      print "Turtle has no Coal, backing to get some"
      turtle.select(1)
      turtle.drop()
      dropItems()
      look(Directions[Init_direction])
      turtle.select(1)
      turtle.suck()
      turtle.select(curSlot)
      backToWork(getLane())
    else
      turtle.select(1)
      turtle.refuel()
      turtle.select(curSlot)
      print ("turtle refuled, current fuel level is: " .. turtle.getFuelLevel())
    end
  end
end

function dropUselessBlocks()
  local curSlot = turtle.getSelectedSlot()
  for slot = 1,16 do
    local item = turtle.getItemDetail(slot)
    if item and string.find(UsellesBlocks(), item.name) then
      turtle.select(slot)
      turtle.drop()
    end
  end
  turtle.select(curSlot)
end

function inventoryFull()
  if turtle.getItemCount(16) > 0 then
    dropUselessBlocks()
    if turtle.getItemCount(16) > 0 then
      print "Inventory is full returning items"
      local curSlot = turtle.getSelectedSlot()
      dropItems()
      turtle.select(curSlot)
      backToWork(getLane())
    end
  end
end

function dropItems()
  goHome(getLane())
  look("back")
  for num = 2,16 do
    turtle.select(num)
    turtle.drop()
  end
end


function moveDown()
  while turtle.detectDown() do
    local success, data = turtle.inspectDown()
    if success and string.find(data.name, "turtle") then
      sleep(1)
    else
      turtle.digDown()
    end
  end
  while not turtle.down() do
    turtle.down()
  end
  updateCoord("down")
end

function moveUp(x)
  for num = 1,x do
    while turtle.detectUp() do
      local success, data = turtle.inspectUp()
      if success and string.find(data.name, "turtle") then
        sleep(1)
      else
        turtle.digUp()
      end
    end
    while not turtle.up() do
      turtle.up()
    end
    updateCoord("up")
  end
end

function moveForward(mining)
  local mining = mining or false
  while turtle.detect() do
    local success, data = turtle.inspect()
    if success and string.find(data.name, "turtle") then
      sleep(1)
    else
      turtle.dig()
    end
  end
  while not turtle.forward() do
    turtle.forward()
  end
  if mining == true then
    turtle.digUp()
    turtle.digDown()
  end
  updateCoord("forward")
end
