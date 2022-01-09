require "utils.mining"
require "utils.block"

function digLayer(area)
  for num = 1,area do
    for i = 1,area do
      hasCoal()
      inventoryFull()
      moveForward(1, true)
    end
    if (num%2) == 1 and num < area then
      tLeft()
      moveForward(1, true)
      tLeft()
    elseif num < area then
      tRight()
      moveForward(1, true)
      tRight()
    end
  end
  turtle.digUp()
  turtle.digdown()
  goTo(xTo, yCoord, zTo)
  look(directions[initDirection])
  for d = 1,3 do
    if yCoord > minLevel then
      moveDown(1)
    end
  end
end

function digQuarry(xQuarry, yQuarry, zQuarry, area, deepth)
  xTo, yTo, zTo = xQuarry, yQuarry, zQuarry
  goTo(xTo, yTo, zTo)
  minLevel = yCoord - oreLevel(deepth)
  print (minLevel)
  while yCoord > minLevel do
    digLayer(area)
  end
  print "Quarry done, going home"
  moveUp((yInit - yCoord) + 10)
  goTo(xInit, yInit, zInit)
end

direction, initDirection = 4, 4
usellesBlocks("Normal")
moveUp((yInit - yCoord) + 10)
digQuarry(-101, 63, 51, 6, "diamont")
