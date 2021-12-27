function refuel()
  if turtle.getFuelLevel() < 10 then
    turtle.refuel()
  end
end

function digForward()
  while turtle.detect() do
    turtle.dig()
  end
end

function moveForward()
  refuel()
  while turtle.forward() == false do
    digForward()
  end
end

function moveBack()
  refuel()
  while turtle.forward() == false do
    turtle.back()
  end
end

for num=1,3 do
  moveForward()
end

for num=1,3 do
  moveBack()
end
