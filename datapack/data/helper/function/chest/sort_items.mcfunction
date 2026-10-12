# Sort items from helper inventory into base chests
# Simplified: just dump all items into the first chest for now

# Get helper position (at base)
execute as @e[tag=helper.active,limit=1] at @s run function helper:chest/sort_into_chest

# Notify player
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Items organized into base chests.","color":"green"}]
playsound minecraft:block.chest.close master @a[limit=1]
