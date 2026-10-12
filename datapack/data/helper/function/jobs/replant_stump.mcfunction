# Place a matching sapling on dirt at the stump (air where the trunk was).
execute unless block ~ ~ ~ #helper:passable run return 0
execute unless block ~ ~-1 ~ #minecraft:dirt unless block ~ ~-1 ~ minecraft:grass_block unless block ~ ~-1 ~ minecraft:podzol unless block ~ ~-1 ~ minecraft:moss_block unless block ~ ~-1 ~ minecraft:mud unless block ~ ~-1 ~ minecraft:rooted_dirt unless block ~ ~-1 ~ minecraft:farmland run return 0
execute if score #kind helper_config matches 1 run setblock ~ ~ ~ minecraft:oak_sapling
execute if score #kind helper_config matches 2 run setblock ~ ~ ~ minecraft:spruce_sapling
execute if score #kind helper_config matches 3 run setblock ~ ~ ~ minecraft:birch_sapling
execute if score #kind helper_config matches 4 run setblock ~ ~ ~ minecraft:jungle_sapling
execute if score #kind helper_config matches 5 run setblock ~ ~ ~ minecraft:acacia_sapling
execute if score #kind helper_config matches 6 run setblock ~ ~ ~ minecraft:dark_oak_sapling
execute if score #kind helper_config matches 7 run setblock ~ ~ ~ minecraft:cherry_sapling
execute if score #kind helper_config matches 8 run setblock ~ ~ ~ minecraft:mangrove_propagule
execute if score #kind helper_config matches 9 run setblock ~ ~ ~ minecraft:pale_oak_sapling
execute if score #kind helper_config matches 0 run setblock ~ ~ ~ minecraft:oak_sapling
# 2x2 trunks get four saplings
execute if score #kind helper_config matches 2 if block ~1 ~-1 ~ #minecraft:dirt run setblock ~1 ~ ~ minecraft:spruce_sapling
execute if score #kind helper_config matches 2 if block ~ ~-1 ~1 #minecraft:dirt run setblock ~ ~ ~1 minecraft:spruce_sapling
execute if score #kind helper_config matches 2 if block ~1 ~-1 ~1 #minecraft:dirt run setblock ~1 ~ ~1 minecraft:spruce_sapling
execute if score #kind helper_config matches 4 if block ~1 ~-1 ~ #minecraft:dirt run setblock ~1 ~ ~ minecraft:jungle_sapling
execute if score #kind helper_config matches 4 if block ~ ~-1 ~1 #minecraft:dirt run setblock ~ ~ ~1 minecraft:jungle_sapling
execute if score #kind helper_config matches 4 if block ~1 ~-1 ~1 #minecraft:dirt run setblock ~1 ~ ~1 minecraft:jungle_sapling
execute if score #kind helper_config matches 6 if block ~1 ~-1 ~ #minecraft:dirt run setblock ~1 ~ ~ minecraft:dark_oak_sapling
execute if score #kind helper_config matches 6 if block ~ ~-1 ~1 #minecraft:dirt run setblock ~ ~ ~1 minecraft:dark_oak_sapling
execute if score #kind helper_config matches 6 if block ~1 ~-1 ~1 #minecraft:dirt run setblock ~1 ~ ~1 minecraft:dark_oak_sapling
