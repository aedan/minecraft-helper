# Organize storage area: build a grid of chests (4x4 = 16 chests) if needed
# Each chest gets a category label

# Check if chests already exist in storage area
execute store result score #chests_exist helper_config run test for blocks ~-8 ~-1 ~-8 ~8 ~1 ~8 minecraft:chest

# If fewer than 16 chests, build more
execute if score #chests_exist helper_config matches ..15 run function helper:storage/build_chest_grid

# Label existing chests by position (simplified: just label the first 16)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:storage/label_chests

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Storage area organized. ","color":"green"},{"text":"16 chests built and labeled.","color":"gray"}]
