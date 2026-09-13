# Calculate distance from helper to owner

# Get helper position
execute as @e[type=villager,tag=helper.active,limit=1] run scoreboard players set #helper_x helper_config < #x
execute as @e[type=villager,tag=helper.active,limit=1] run scoreboard players set #helper_y helper_config < #y
execute as @e[type=villager,tag=helper.active,limit=1] run scoreboard players set #helper_z helper_config < #z

# Get owner position (already stored in #owner_x, #owner_y, #owner_z)

# Calculate distance (simplified: just use X distance for now)
execute store result score #owner_dist helper_config run function helper:combat/calc_x_distance
