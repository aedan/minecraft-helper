# Walk backward along look: skip empties, then count consecutive normal rails until powered.
# Result in #rail_phase = normals since last powered at the tip (0 if tip is powered).
scoreboard players add #rail_scan helper_config 1
scoreboard players set #rail_tip helper_config 0

# Pick lane: dual/left → left; right-only → right; else center
scoreboard players set #rail_lane helper_config 2
execute if score #rail_mask helper_config matches 1 run scoreboard players set #rail_lane helper_config 1
execute if score #rail_mask helper_config matches 5 run scoreboard players set #rail_lane helper_config 1
execute if score #rail_mask helper_config matches 4 run scoreboard players set #rail_lane helper_config 4
execute if score #rail_mask helper_config matches 3 run scoreboard players set #rail_lane helper_config 1
execute if score #rail_mask helper_config matches 6 run scoreboard players set #rail_lane helper_config 4
execute if score #rail_mask helper_config matches 7 run scoreboard players set #rail_lane helper_config 1

# Classify tip block on chosen lane (1=normal rail, 2=powered, 0=empty/other)
execute if score #rail_lane helper_config matches 1 if block ^-1 ^ ^ minecraft:powered_rail run scoreboard players set #rail_tip helper_config 2
execute if score #rail_lane helper_config matches 1 if score #rail_tip helper_config matches 0 if block ^-1 ^-1 ^ minecraft:powered_rail run scoreboard players set #rail_tip helper_config 2
execute if score #rail_lane helper_config matches 1 if score #rail_tip helper_config matches 0 if block ^-1 ^ ^ minecraft:rail run scoreboard players set #rail_tip helper_config 1
execute if score #rail_lane helper_config matches 1 if score #rail_tip helper_config matches 0 if block ^-1 ^-1 ^ minecraft:rail run scoreboard players set #rail_tip helper_config 1

execute if score #rail_lane helper_config matches 4 if block ^1 ^ ^ minecraft:powered_rail run scoreboard players set #rail_tip helper_config 2
execute if score #rail_lane helper_config matches 4 if score #rail_tip helper_config matches 0 if block ^1 ^-1 ^ minecraft:powered_rail run scoreboard players set #rail_tip helper_config 2
execute if score #rail_lane helper_config matches 4 if score #rail_tip helper_config matches 0 if block ^1 ^ ^ minecraft:rail run scoreboard players set #rail_tip helper_config 1
execute if score #rail_lane helper_config matches 4 if score #rail_tip helper_config matches 0 if block ^1 ^-1 ^ minecraft:rail run scoreboard players set #rail_tip helper_config 1

execute if score #rail_lane helper_config matches 2 if block ~ ~ ~ minecraft:powered_rail run scoreboard players set #rail_tip helper_config 2
execute if score #rail_lane helper_config matches 2 if score #rail_tip helper_config matches 0 if block ~ ~-1 ~ minecraft:powered_rail run scoreboard players set #rail_tip helper_config 2
execute if score #rail_lane helper_config matches 2 if score #rail_tip helper_config matches 0 if block ~ ~ ~ minecraft:rail run scoreboard players set #rail_tip helper_config 1
execute if score #rail_lane helper_config matches 2 if score #rail_tip helper_config matches 0 if block ~ ~-1 ~ minecraft:rail run scoreboard players set #rail_tip helper_config 1

# Powered tip → phase 0
execute if score #rail_tip helper_config matches 2 run return 0
# Normal → count and continue back
execute if score #rail_tip helper_config matches 1 run scoreboard players add #rail_phase helper_config 1
execute if score #rail_tip helper_config matches 1 if score #rail_scan helper_config matches ..32 positioned ^ ^ ^-1 run function helper:jobs/rail_learn_phase
# Empty before any rail found → keep skipping back; empty after counting → stop
execute if score #rail_tip helper_config matches 0 if score #rail_phase helper_config matches 0 if score #rail_scan helper_config matches ..32 positioned ^ ^ ^-1 run function helper:jobs/rail_learn_phase
