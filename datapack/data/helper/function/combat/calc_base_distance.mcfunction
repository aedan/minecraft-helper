# Calculate distance from helper to base

# Get helper position
execute as @e[tag=helper.active,limit=1] store result score #hx helper_config run data get entity @s Pos[0]
execute as @e[tag=helper.active,limit=1] store result score #hy helper_config run data get entity @s Pos[1]
execute as @e[tag=helper.active,limit=1] store result score #hz helper_config run data get entity @s Pos[2]

# Calculate X distance
scoreboard players operation #dx helper_config = #hx helper_config
scoreboard players operation #dx helper_config -= #base_x helper_config

# Use X distance as approximation for now
scoreboard players operation #base_dist helper_config = #dx helper_config
