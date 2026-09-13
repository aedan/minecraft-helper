# Return to base: teleport to base coordinates, then organize chests

# Get base coordinates
execute store result entity @e[type=villager,tag=helper.active,limit=1] Pos[0] double 1 run scoreboard players get #base_x helper_config
execute store result entity @e[type=villager,tag=helper.active,limit=1] Pos[1] double 1 run scoreboard players get #base_y helper_config
execute store result entity @e[type=villager,tag=helper.active,limit=1] Pos[2] double 1 run scoreboard players get #base_z helper_config

# Teleport helper to base
execute as @e[type=villager,tag=helper.active,limit=1] run tp @s ~1 ~ ~1

# Play return sound
execute as @e[type=villager,tag=helper.active,limit=1] at @s run playsound minecraft:entity.enderman.teleport master @s

# Organize chests after returning
function helper:chest/organize

# Notify player
tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Returned to base and organized supplies.","color":"green"}]
