# Command: /helper craft <item> - Craft a specific item
# Simplified: just give the item to the player for now

# Full implementation would:
# 1. Look up recipe for the item
# 2. Check inventory for required materials
# 3. If missing, go find them
# 4. Craft the item
# 5. Deliver to player

tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Crafting requested. ","color":"green"},{"text":"(Full crafting system coming soon)"}]

# Placeholder: give a diamond sword
execute as @s run item give @s minecraft:diamond_sword 1
