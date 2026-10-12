# Shaft down while hunting underground ores. Stop near deepslate diamond level.
execute store result score #hy helper_config run data get entity @s Pos[1]
execute if score #hy helper_config matches ..-58 run return 0
execute if block ~ ~-1 ~ minecraft:bedrock run return 0
execute if block ~ ~-1 ~ #minecraft:logs run return 0
execute if block ~ ~-1 ~ minecraft:air run tp @s ~ ~-1 ~
execute if block ~ ~-1 ~ minecraft:cave_air run tp @s ~ ~-1 ~
execute if block ~ ~-1 ~ minecraft:stone run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:deepslate run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:tuff run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:granite run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:diorite run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:andesite run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:dirt run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:grass_block run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:gravel run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:netherrack run setblock ~ ~-1 ~ air destroy
execute if block ~ ~-1 ~ minecraft:air run tp @s ~ ~-1 ~
function helper:jobs/probe
