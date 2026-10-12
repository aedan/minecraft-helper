# Check if helper has fuel in inventory (via item check)

execute as @e[tag=helper.active,limit=1] if items entity @s inventory.0 minecraft:oak_log run scoreboard players set #has_fuel helper_config 1
execute as @e[tag=helper.active,limit=1] if items entity @s inventory.0 minecraft:spruce_log run scoreboard players set #has_fuel helper_config 1
execute as @e[tag=helper.active,limit=1] if items entity @s inventory.0 minecraft:coal run scoreboard players set #has_fuel helper_config 1
execute as @e[tag=helper.active,limit=1] if items entity @s inventory.0 minecraft:charcoal run scoreboard players set #has_fuel helper_config 1
execute as @e[tag=helper.active,limit=1] if items entity @s inventory.1 minecraft:oak_log run scoreboard players set #has_fuel helper_config 1

# Default to 0 if nothing found
execute unless score #has_fuel helper_config matches 1 run scoreboard players set #has_fuel helper_config 0
