# Calculate distance from helper to base

# Get helper position
execute as @e[type=villager,tag=helper.active,limit=1] run scoreboard players set #helper_x helper_config < #x
execute as @e[type=villager,tag=helper.active,limit=1] run scoreboard players set #helper_y helper_config < #y
execute as @e[type=villager,tag=helper.active,limit=1] run scoreboard players set #helper_z helper_config < #z

# Get base position (already stored in #base_x, #base_y, #base_z)

# Calculate distance (simplified: just use X distance for now)
execute store result score #base_dist helper_config run function helper:combat/calc_x_distance
