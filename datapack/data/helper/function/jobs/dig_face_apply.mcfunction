# As helper. Face #pick (0 south, 90 west, 180 north, -90 east), pitch 0. Position unchanged.
execute if score #pick helper_config matches 0 at @s run tp @s ~ ~ ~ 0 0
execute if score #pick helper_config matches 90 at @s run tp @s ~ ~ ~ 90 0
execute if score #pick helper_config matches 180 at @s run tp @s ~ ~ ~ 180 0
execute if score #pick helper_config matches -90 at @s run tp @s ~ ~ ~ -90 0
