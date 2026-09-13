# Check if helper has fuel in inventory
# Fuel: oak_log, spruce_log, birch_log, coal, charcoal, blaze_rod

execute if item @s inventory.* minecraft:oak_log run scoreboard players set #has_fuel helper_config 1
execute if item @s inventory.* minecraft:spruce_log run scoreboard players set #has_fuel helper_config 1
execute if item @s inventory.* minecraft:birch_log run scoreboard players set #has_fuel helper_config 1
execute if item @s inventory.* minecraft:coal run scoreboard players set #has_fuel helper_config 1
execute if item @s inventory.* minecraft:charcoal run scoreboard players set #has_fuel helper_config 1
execute if item @s inventory.* minecraft:blaze_rod run scoreboard players set #has_fuel helper_config 1

# Default to 0 if nothing found
execute unless score #has_fuel helper_config matches 1 run scoreboard players set #has_fuel helper_config 0
