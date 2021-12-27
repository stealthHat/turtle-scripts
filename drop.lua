usellesBlocks = "minecraft:cobbled_deepslate minecraft:diorite minecraft:andesite minecraft:cobblestone minecraft:dirt minecraft:tuff minecraft:gravel minecraft:sand minecraft:granite"

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

dropUselessBlocks()
