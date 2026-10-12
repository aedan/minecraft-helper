# Tree cutting system: find and completely fell a tree, then replant

# Find nearest tree (oak/spruce/birch log) within 32 blocks
execute store result score #tree_found helper_config run data get block ~ ~ ~ minecraft:oak_log

# If tree found, cut it down
execute if score #tree_found helper_config matches 1 run function helper:tree/cut_tree

# If no tree found, notify
execute if score #tree_found helper_config matches 0 run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"yellow"},{"text":"No trees found within 32 blocks. ","color":"gray"}]
