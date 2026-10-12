# Build furnace setup once at the base marker (caller positioned at marker).
execute unless block ~1 ~ ~ minecraft:furnace unless block ~1 ~ ~ minecraft:blast_furnace run setblock ~1 ~ ~ minecraft:blast_furnace
execute unless block ~2 ~ ~ minecraft:smoker run setblock ~2 ~ ~ minecraft:smoker
execute unless block ~3 ~ ~ minecraft:furnace run setblock ~3 ~ ~ minecraft:furnace
execute unless block ~1 ~-1 ~ minecraft:hopper run setblock ~1 ~-1 ~ minecraft:hopper
execute unless block ~2 ~-1 ~ minecraft:hopper run setblock ~2 ~-1 ~ minecraft:hopper
execute unless block ~3 ~-1 ~ minecraft:hopper run setblock ~3 ~-1 ~ minecraft:hopper
execute unless block ~2 ~-2 ~ minecraft:chest run setblock ~2 ~-2 ~ minecraft:chest
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Built a smelting setup at base.","color":"green"}]
