# Tree cutting system: find and completely fell a tree, then replant
# Uses axe for wood, shovel for dirt/roots, pickaxe for stone

# Find nearest tree (oak/spruce/birch log) within 32 blocks
execute store result score #tree_found helper_config run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:oak_log

# If no oak, try spruce
execute if score #tree_found helper_config matches 0 run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:spruce_log
execute if score #tree_found helper_config matches 0 run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:birch_log

# If tree found, cut it down
execute if score #tree_found helper_config matches 1 run function helper:tree/cut_tree

# If no tree found, notify
execute if score #tree_found helper_config matches 0 run tellraw @a[limit=1] [{"text":"[Helper] ","color":"yellow"},{"text":"No trees found within 32 blocks. ","color":"gray"},{"text":"Will search further.","color":"gray"}]
