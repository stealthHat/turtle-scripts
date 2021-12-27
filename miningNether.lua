usellesBlocks = "minecraft:flint create:scoria create:scorchia minecraft:smooth_basalt minecraft:soul_sand minecraft:soul_soil minecraft:soorchia minecraft:magma_block  minecraft:cobblestone minecraft:gravel minecraft:netherrack minecraft:nether_bricks minecraft:blackstone minecraft:basalt"

function dropUselessBlocks(blocks)
  curSlot = turtle.getSelectedSlot()
  for slot = 1,16 do
    local item = turtle.getItemDetail(slot)
    if item and string.find(blocks, item.name) then
      turtle.select(slot)
      turtle.drop()
    end
  end
  turtle.select(curSlot)
end

function refuel()
  curSlot = turtle.getSelectedSlot()
  if turtle.getFuelLevel() < 5000 then
    turtle.select(1)
    turtle.refuel()
    turtle.select(curSlot)
  end
end

function digDown(x)
  for num = 1,x do
    while turtle.detectDown() do
      turtle.digDown()
    end
    turtle.down()
    refuel()
  end
end

function digUp(x)
  for num = 1,x do
    while turtle.detectUp() do
      turtle.digUp()
    end
    turtle.up()
    dropUselessBlocks(usellesBlocks)
    refuel()
  end
end

function digForward(x)
  for num = 1,x do
    while turtle.detect() do
     turtle.dig()
    end
    turtle.forward()
    turtle.digUp()
    turtle.digDown()
    dropUselessBlocks(usellesBlocks)
    refuel()
  end
end

digDown(54)

digForward(100)

turtle.turnRight()
digForward(1)
turtle.turnRight()

digForward(100)

turtle.turnRight()
turtle.forward()
turtle.turnLeft()

digForward(100)

turtle.turnLeft()
digForward(1)
turtle.turnLeft()

digForward(100)

digUp(54)
