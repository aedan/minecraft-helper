# Build a row of 5 chests in front of the base location

# Get base position (already set in helper_config)
execute store result entity @e[type=villager,tag=helper.active,limit=1] Pos[0] double 1 run scoreboard players get #base_x helper_config
execute store result entity @e[type=villager,tag=helper.active,limit=1] Pos[1] double 1 run scoreboard players get #base_y helper_config
execute store result entity @e[type=villager,tag=helper.active,limit=1] Pos[2] double 1 run scoreboard players get #base_z helper_config

# Build chest row (5 chests in a line)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~1 ~ ~ minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~2 ~ ~ minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~3 ~ ~ minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~4 ~ ~ minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~5 ~ ~ minecraft:chest

# Add labels to chests (optional)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~1 ~ ~ {front_text:{messages:[{"text":"Supplies","color":"aqua"}]}}
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~2 ~ ~ {front_text:{messages:[{"text":"Resources","color":"green"}]}}
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~3 ~ ~ {front_text:{messages:[{"text":"Food","color":"yellow"}]}}
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~4 ~ ~ {front_text:{messages:[{"text":"Tools","color":"blue"}]}}
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~5 ~ ~ {front_text:{messages:[{"text":"Misc","color":"gray"}]}}

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Built 5 supply chests at base.","color":"green"}]
playsound minecraft:block.chest.open master @a[limit=1]
