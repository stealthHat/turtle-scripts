local function stackItems()
    for i = 1, 16 do
        local currentSlot = turtle.getItemDetail(i)
        if currentSlot then
            for j = i + 1, 16 do
                local compareSlot = turtle.getItemDetail(j)
                if compareSlot and currentSlot.name == compareSlot.name then
                    turtle.select(j)
                    turtle.transferTo(i)
                end
            end
        end
    end
    turtle.select(1)
end

stackItems()
