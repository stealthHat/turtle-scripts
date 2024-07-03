local movements = {}

local locale = require "utils.locale"
local actions = require "utils.actions"

function movements.go_to(coord)
  if State.coord.x < coord.x then
    locale.face "east"

    while State.coord.x < coord.x do
      actions.move "forward"
      locale.update_coord "forward"
    end
  else
    locale.face "west"

    while State.coord.x > coord.x do
      actions.move "forward"
      locale.update_coord "forward"
    end
  end

  if State.coord.z < coord.z then
    locale.face "south"

    while State.coord.z < coord.z do
      actions.move "forward"
      locale.update_coord "forward"
    end
  else
    locale.face "north"

    while State.coord.z > coord.z do
      actions.move "forward"
      locale.update_coord "forward"
    end
  end

  while State.coord.y < coord.y do
    actions.move "up"
    locale.update_coord "up"
  end

  while State.coord.y > coord.y do
    actions.move "down"
    locale.update_coord "down"
  end
end

return movements
