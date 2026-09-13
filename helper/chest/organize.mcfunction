# Chest organization system: sort items into base chests, build more if needed
# Runs when helper returns from a task

# Check if base chests exist (within 8 blocks of base)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:chest/check_chests

# If no chests, build a chest row
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:chest/build_chests

# Sort items into chests
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:chest/sort_items
