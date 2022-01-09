function usellesBlocks(world)
  if world == "Nether" then
    curUsellesBlocks = "minecraft:flint " ..
      "create:scoria " ..
      "create:scorchia " ..
      "minecraft:smooth_basalt " ..
      "minecraft:soul_sand " ..
      "minecraft:soul_soil " ..
      "minecraft:soorchia " ..
      "minecraft:magma_block  " ..
      "minecraft:cobblestone " ..
      "minecraft:gravel " ..
      "minecraft:netherrack " ..
      "minecraft:nether_bricks " ..
      "minecraft:blackstone " ..
      "minecraft:basalt"
  elseif world == "Normal" then
    curUsellesBlocks  = "create:limestone " ..
      "create:ochrum " ..
      "create:crimsite " ..
      "create:veridium " ..
      "create:asurine " ..
      "consistency_plus:cobbled_andesite " ..
      "consistency_plus:cobbled_tuff " ..
      "consistency_plus:cobbled_granite " ..
      "consistency_plus:cobbled_dripstone " ..
      "consistency_plus:cobbled_diorite " ..
      "consistency_plus:cobbled_calcite " ..
      "minecraft:calcite " ..
      "minecraft:smooth_basalt " ..
      "minecraft:flint " ..
      "minecraft:cobbled_deepslate " ..
      "minecraft:diorite " ..
      "minecraft:cobblestone " ..
      "minecraft:dirt " ..
      "minecraft:tuff " ..
      "minecraft:gravel " ..
--      "minecraft:sand " ..
      "minecraft:granite " ..
      "minecraft:clay_ball"
  end
end

