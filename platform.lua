slot = 1

function placeDown()
  if turtle.getItemCount(slot) == 0 then
    slot = slot + 1
    turtle.select(slot)
  end
  turtle.placeDown()
end

function Layer(x,z)
  for num = 1,z do
    for i = 1,(x -1) do
      placeDown()
      turtle.forward()
    end
    if (num%2) == 1 and num < x then
      turtle.turnLeft()
      turtle.forward()
      placeDown()
      turtle.turnLeft()
    elseif num < x then
      turtle.turnRight()
      turtle.forward()
      placeDown()
      turtle.turnRight()
    end
  end
end

print "X How big?"
local xInput = read()
print "Z How big?"
local zInput = read()
Layer(tonumber(xInput),tonumber(zInput))
