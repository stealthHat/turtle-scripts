package.path = package.path .. ";../../?.lua"

local locale = require "utils.locale"
local actions = require "utils.actions"

local control_plane = rednet.lookup("manager3", "manager3")
local work = true

local function go_to_lane()
  local up = (State.init_coord.y - State.coord.y) + os.getComputerLabel():gsub("%D+", "")
  for _ = 1, up do
    locale.move "up"
  end
end

local function go_home()
  State.prog_coord = { x = State.coord.x, y = State.coord.y, z = State.coord.z }
  State.prog_facing = State.facing

  go_to_lane()

  locale.go_to(State.init_coord)
  locale.face(State.init_facing)
end

local function back_to_work()
  go_to_lane()

  locale.go_to(State.prog_coord)
  locale.face(State.prog_facing)
end

local function drop_items()
  go_home()

  locale.turn "right"

  local item = turtle.getItemDetail(1)

  if item and not string.find(locale.actions.fuel_blocks, item.name) then
    turtle.select(1)
    turtle.drop()
  end

  for slot = 2, 16 do
    turtle.select(slot)
    turtle.drop()
  end
end

local function inventory_check()
  if turtle.getItemCount(16) > 0 then
    actions.drop_useless_blocks()

    if turtle.getItemCount(16) > 0 then
      actions.stack_and_organize_items()
    end

    if turtle.getItemCount(16) > 0 then
      print "Inventory is full returning items"
      drop_items()
      back_to_work()
    end
  end
end

local function fuel_check()
  if not actions.refuel(5000) then
    print "Turtle has no Coal, backing to get some"
    drop_items()
    locale.face(State.init_facing)
    locale.turn "left"
    turtle.suck()
    back_to_work()
  end
end

local function act_and_check(func, check)
  func()
  check()
end

local function move_and_dig()
  act_and_check(actions.dig "forward", inventory_check())
  act_and_check(actions.move "forward", fuel_check())
end

local function dig_layer(width)
  for row = 1, width do
    for _ = 1, (width - 1) do
      move_and_dig()
    end

    if row < width and row % 2 == 1 then
      locale.turn "left"
      move_and_dig()
      locale.turn "left"
    elseif row < width then
      locale.turn "right"
      move_and_dig()
      locale.turn "right"
    end
  end
end

local function dig_quarry(x, y, z, width, depth)
  locale.go_to { x = x, y = y, z = z }
  locale.face(State.init_facing)

  while depth < State.location.y do
    dig_layer(width)
    locale.go_to { x = x, y = State.coord.y, z = z }

    if depth < State.location.y then
      act_and_check(actions.dig "down", inventory_check())
      act_and_check(actions.move "down", fuel_check())
    end
  end

  print "Quarry done, getting another job"
  go_to_lane()
end

local function get_job()
  while work do
    print "Requesting Job"
    rednet.send(control_plane, "getJob")

    local _, message, _ = rednet.receive()

    if message == "yes" then
      local _, job_string, _ = rednet.receive()
      local chunk = load("return " .. job_string)

      if chunk then
        local job = chunk()
        print("Job available at " .. job.x .. " " .. job.z)

        dig_quarry(job.x, job.y, job.z, job.width, job.depth)

        print "Quarry done"
      end
    elseif message == "no" then
      print "No more jobs, going home"
      work = false
      go_home()
    end
  end
end

rednet.close "right"
rednet.open "right"
actions.refuel(5000)
locale.calibrate()
go_to_lane()
get_job()
