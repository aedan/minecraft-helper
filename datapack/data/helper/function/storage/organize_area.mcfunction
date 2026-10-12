# Organize storage area: build a grid of chests (4x4 = 16 chests) if needed

# Check if a chest already exists at the storage center (via execute if block)
execute if block ~ ~ ~ minecraft:chest run scoreboard players set #chests_exist helper_config 1
execute unless block ~ ~ ~ minecraft:chest run scoreboard players set #chests_exist helper_config 0

# If no chest at center, build the grid
execute if score #chests_exist helper_config matches 0 run function helper:storage/build_chest_grid

# Label existing chests
execute as @e[tag=helper.active,limit=1] at @s run function helper:storage/label_chests

tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Storage area organized. ","color":"green"},{"text":"Chests built and labeled.","color":"gray"}]
