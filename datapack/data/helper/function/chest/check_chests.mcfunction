# Check if base chests exist within 8 blocks of base coordinates

# Get base position
execute store result entity @e[tag=helper.active,limit=1] Pos[0] double 1 run scoreboard players get #base_x helper_config
execute store result entity @e[tag=helper.active,limit=1] Pos[1] double 1 run scoreboard players get #base_y helper_config
execute store result entity @e[tag=helper.active,limit=1] Pos[2] double 1 run scoreboard players get #base_z helper_config

# Check for chests in 8-block radius
execute if block ~ ~ ~ minecraft:chest run scoreboard players set #chests_found helper_config 1
execute unless block ~ ~ ~ minecraft:chest run scoreboard players set #chests_found helper_config 0

# If no chests found, trigger build
execute if score #chests_found helper_config matches 0 run function helper:chest/build_chests
