# Build a furnace + smoker + blast furnace setup at base
# Positions: ~1 ~ ~ (furnace), ~2 ~ ~ (smoker), ~3 ~ ~ (blast furnace)

execute as @e[tag=helper.active,limit=1] at @s run setblock ~1 ~ ~ minecraft:furnace
execute as @e[tag=helper.active,limit=1] at @s run setblock ~2 ~ ~ minecraft:smoker
execute as @e[tag=helper.active,limit=1] at @s run setblock ~3 ~ ~ minecraft:blast_furnace

# Add hoppers below to collect output
execute as @e[tag=helper.active,limit=1] at @s run setblock ~1 ~-1 ~ minecraft:hopper
execute as @e[tag=helper.active,limit=1] at @s run setblock ~2 ~-1 ~ minecraft:hopper
execute as @e[tag=helper.active,limit=1] at @s run setblock ~3 ~-1 ~ minecraft:hopper

# Add chest below hoppers
execute as @e[tag=helper.active,limit=1] at @s run setblock ~2 ~-2 ~ minecraft:chest
data merge block ~2 ~-2 ~ {front_text:{messages:[{"text":"Smelted","color":"orange","bold":true}]}}

tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Built smelting setup: furnace, smoker, blast furnace with hoppers.","color":"green"}]
