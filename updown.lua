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

digDown(54)
digUp(54)
