# Load furnace with ore and food
# Simplified: put items in furnace input slots

# Get items from helper inventory and put in furnace
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ Items[0] set from entity @s Inventory[0]
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ Items[1] set from entity @s Inventory[1]
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ Items[2] set from entity @s Inventory[2]

# Add fuel to furnace
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ Items[1] set value {id:"minecraft:oak_log",count:16b}

# Start furnace
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ lit boolean set value 1b

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Furnace loaded with ore and fuel. ","color":"green"},{"text":"Smelting in progress...","color":"yellow"}]
