# Auto-smelting system: smelt ore and cook food
# Uses fuel from inventory or goes to find wood

# Check if furnace exists near base
execute store result score #furnace_found helper_config run test for blocks ~-4 ~-2 ~-4 ~4 ~2 ~4 minecraft:furnace

# If no furnace, build one
execute if score #furnace_found helper_config matches 0 run function helper:smelt/build_furnace

# Check for fuel in inventory (wood, coal, charcoal)
execute as @e[type=villager,tag=helper.active,limit=1] run function helper:smelt/check_fuel

# If no fuel, go find wood
execute if score #has_fuel helper_config matches 0 run function helper:smelt/find_fuel

# Put ore in furnace
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:smelt/load_furnace

# Notify
tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Smelting system active. ","color":"green"},{"text":"Ore being smelted, food being cooked.","color":"gray"}]
