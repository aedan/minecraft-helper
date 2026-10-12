# As helper. If the chosen facing would dig bedrock immediately, try the other
# horizontal directions for a diggable solid. #dig_abort = 1 when none exist.
scoreboard players set #dig_abort helper_config 0
execute at @s unless block ^ ^ ^1 minecraft:bedrock unless block ^ ^1 ^1 minecraft:bedrock run return 0
scoreboard players set #found_face helper_config 0
execute at @s rotated 0 0 run function helper:jobs/dig_try_face
execute at @s rotated 90 0 run function helper:jobs/dig_try_face
execute at @s rotated 180 0 run function helper:jobs/dig_try_face
execute at @s rotated -90 0 run function helper:jobs/dig_try_face
execute if score #found_face helper_config matches 0 run scoreboard players set #dig_abort helper_config 1
