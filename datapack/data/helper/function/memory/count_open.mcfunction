# Facing a cardinal, count 2-tall passable cells ahead (max 16).
# #face helper_config: 0 unknown/open-ended, 1 diggable solid, 2 bedrock.
# Called recursively one block forward. Does not count the starting cell.
execute if score #open helper_config matches 16.. run return 0
execute if block ^ ^ ^1 minecraft:bedrock run scoreboard players set #face helper_config 2
execute if block ^ ^ ^1 minecraft:bedrock run return 0
execute if block ^ ^1 ^1 minecraft:bedrock run scoreboard players set #face helper_config 2
execute if block ^ ^1 ^1 minecraft:bedrock run return 0
execute if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run scoreboard players add #open helper_config 1
execute if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable positioned ^ ^ ^1 run function helper:memory/count_open
execute if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run return 0
execute if block ^ ^ ^1 minecraft:barrier run return 0
execute if block ^ ^ ^1 minecraft:command_block run return 0
execute if block ^ ^1 ^1 minecraft:barrier run return 0
execute if block ^ ^1 ^1 minecraft:command_block run return 0
scoreboard players set #face helper_config 1
