# Sort items into a specific chest
# For now, just transfer all items from helper inventory to chest at ~1 ~ ~

# Get helper inventory items (simplified: just give items to chest)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data modify block ~1 ~ ~ Items set from entity @s Inventory

# Clear helper inventory after sorting
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data modify entity @s Inventory set value []
