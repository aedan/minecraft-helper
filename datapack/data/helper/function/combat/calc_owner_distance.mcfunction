# Calculate distance from helper to owner

# Get helper position
execute as @e[tag=helper.active,limit=1] store result score #hx helper_config run data get entity @s Pos[0]
execute as @e[tag=helper.active,limit=1] store result score #hy helper_config run data get entity @s Pos[1]
execute as @e[tag=helper.active,limit=1] store result score #hz helper_config run data get entity @s Pos[2]

# Get owner position
execute as @a[limit=1] store result score #ox helper_config run data get entity @s Pos[0]

# Calculate X distance
scoreboard players operation #dx helper_config = #hx helper_config
scoreboard players operation #dx helper_config -= #ox helper_config

# Use X distance as approximation for now
scoreboard players operation #owner_dist helper_config = #dx helper_config
