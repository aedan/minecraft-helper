# Build a 4x4 grid of chests in the storage area
# Chests at positions: -8,-6,-4,-2,0,2,4,6 on X and Z axes (relative to center)

# Row 1 (Z = -8)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-8 ~ ~-8 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-6 ~ ~-8 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-4 ~ ~-8 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-2 ~ ~-8 minecraft:chest

# Row 2 (Z = -6)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-8 ~ ~-6 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-6 ~ ~-6 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-4 ~ ~-6 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-2 ~ ~-6 minecraft:chest

# Row 3 (Z = -4)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-8 ~ ~-4 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-6 ~ ~-4 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-4 ~ ~-4 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-2 ~ ~-4 minecraft:chest

# Row 4 (Z = -2)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-8 ~ ~-2 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-6 ~ ~-2 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-4 ~ ~-2 minecraft:chest
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~-2 ~ ~-2 minecraft:chest
