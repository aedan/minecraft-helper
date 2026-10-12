# Execution is already rotated to a candidate yaw. Lock the first diggable solid
# that is not bedrock/barrier/command_block (feet ahead). Head must not be those either.
execute if score #found_face helper_config matches 1.. run return 0
execute if block ^ ^ ^1 #helper:passable run return 0
execute if block ^ ^ ^1 minecraft:bedrock run return 0
execute if block ^ ^ ^1 minecraft:barrier run return 0
execute if block ^ ^ ^1 minecraft:command_block run return 0
execute if block ^ ^1 ^1 minecraft:bedrock run return 0
execute if block ^ ^1 ^1 minecraft:barrier run return 0
execute if block ^ ^1 ^1 minecraft:command_block run return 0
scoreboard players set #found_face helper_config 1
tp @s ~ ~ ~ ~ ~
