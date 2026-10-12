# Calculate distance from helper to base (X-axis only, absolute value)

# Store helper X position
execute as @e[tag=helper.active,limit=1] store result score #hx helper_config run data get entity @s Pos[0]

# Get base X
execute store result score #bx helper_config run scoreboard players get #base_x helper_config

# Calculate difference
scoreboard players operation #dx helper_config = #hx helper_config
scoreboard players operation #dx helper_config -= #bx helper_config

# Make absolute (if negative, flip)
execute if score #dx helper_config matches ..-1 run scoreboard players operation #dx helper_config = #-dx helper_config

# Store result
scoreboard players operation #base_dist helper_config = #dx helper_config
