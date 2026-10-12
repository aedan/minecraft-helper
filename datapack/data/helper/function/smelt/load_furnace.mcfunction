# Load furnace with ore and fuel

# Get items from helper inventory and put in furnace
execute as @e[tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ Items set from entity @s Inventory

# Add fuel to furnace
execute as @e[tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ Items[1] set value {id:"minecraft:oak_log",count:16b}

# Start furnace
execute as @e[tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ lit_id set value 0

tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Furnace loaded. ","color":"green"},{"text":"Smelting in progress...","color":"yellow"}]
