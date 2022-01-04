direction = 4

x, y, z = gps.locate(5)
directions = { "north", "east", "south", "west" }

function dropUselessBlocks(blocks)
  local usellesBlocks =  "create:limestone " ..
  "create:ochrum " ..
  "create:crimsite " ..
  "create:veridium " ..
  "create:asurine " ..
  "consistency_plus:cobbled_andesite " ..
  "consistency_plus:cobbled_tuff " ..
  "consistency_plus:cobbled_granite " ..
  "consistency_plus:cobbled_dripstone " ..
  "consistency_plus:cobbled_diorite " ..
  "consistency_plus:cobbled_calcite " ..
  "minecraft:calcite " ..
  "minecraft:smooth_basalt " ..
  "minecraft:flint " ..
  "minecraft:cobbled_deepslate " ..
  "minecraft:diorite " ..
  "minecraft:cobblestone " ..
  "minecraft:dirt " ..
  "minecraft:tuff " ..
  "minecraft:gravel " ..
  "minecraft:sand " ..
  "minecraft:granite " ..
  "minecraft:clay_ball"

  local curSlot = turtle.getSelectedSlot()
  for slot = 1,16 do
    local item = turtle.getItemDetail(slot)
    if item and string.find(usellesBlocks , item.name) then
      turtle.select(slot)
      turtle.drop()
    end
  end
  turtle.select(curSlot)
end

function refuel()
  local curSlot = turtle.getSelectedSlot()
  if turtle.getFuelLevel() < 5000 then
    turtle.select(1)
    turtle.refuel()
    turtle.select(curSlot)
    print ("turtle refuled, current fuel level is: " .. turtle.getFuelLevel())
  end
end

function updateDirection(turn)
  direction = direction - 1
  if turn == "left" then
    direction = (direction - 1 ) % 4
  elseif turn == "right" then
    direction = (direction + 1 ) % 4
  end
  direction = direction + 1
end

function tLeft()
  updateDirection("left")
  turtle.turnLeft()
end

function tRight()
  updateDirection("right")
  turtle.turnLeft()
end

function moveDown(x)
  for num = 1,x do
    refuel()
    while turtle.detectDown() do
      print "Block underneath, diging and trying again ..."
      turtle.digDown()
    end
    while not turtle.down() do
      print "Could move down, trying again ..."
      turtle.down()
    end
    print("moved down ".. num)
  end
end

function moveUp(x)
  for num = 1,x do
    refuel()
    while turtle.detectUp() do
      print "Block above, diging and trying again ..."
      turtle.digUp()
    end
    while not turtle.up() do
      print "Could move up, trying again ..."
      turtle.up()
    end
    print("moved up ".. num)
  end
end

function moveForward(x)
  for num = 1,x do
    refuel()
    while turtle.detect() do
      print "Block ahead, diging and trying again ..."
      turtle.dig()
    end
    turtle.digUp()
    turtle.digDown()
    while not turtle.forward() do
      print "Could move ahead, trying again ..."
      turtle.forward()
    end
    print("moved ".. num)
    dropUselessBlocks()
  end
end

function look(turn)
  while turn ~= directions[direction] do
    tRight()
  end
end

function goTo(xTarget, yTarget, zTarget)
  while yTarget < y do
    moveDown()
  end
  while yTarget > y do
    moveUp()
  end
  if xTarget < x then
    look("west")
    while xTarget < x do
      moveForward()
    end
  end
  if xTarget > x then
    look("east")
    while xTarget > x do
      moveForward()
    end
  end
  if zTarget < z then
    look("north")
    while zTarget < z do
      moveForward()
    end
  end
  if zTarget > z then
    look("south")
    while zTarget > z do
      moveForward()
    end
  end
end

moveForward(5)
