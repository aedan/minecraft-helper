# Hostile threat: any hostile mob within 24 blocks of base gets destroyed
# They don't even get to enter

# Find nearest hostile within 24 blocks
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:trust/engage_hostile
