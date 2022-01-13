slot = 1

function placeBlock()
  if turtle.getItemCount(slot) == 0 then
    slot = slot + 1
    turtle.select(slot)
  end
  turtle.placeDown()
end

function makeLayer(x,z)
  for num = 1,z do
    for i = 1,(x -1) do
      turtle.forward()
      placeBlock()
    end
    if (num%2) == 1 and num < x then
      turtle.turnLeft()
      turtle.forward()
      placeBlock()
      turtle.turnLeft()
    elseif num < x then
      turtle.turnRight()
      turtle.forward()
      placeBlock()
      turtle.turnRight()
    end
  end
end

print "X How big?"
local xInput = read()
print "Z How big?"
local zInput = read()
makeLayer(tonumber(xInput),tonumber(zInput))
