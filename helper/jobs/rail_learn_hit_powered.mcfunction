# Record powered_rail for period. Period = normals BETWEEN two powered (not phase-to-first).
scoreboard players add #rail_pow helper_config 1
execute if score #rail_pow helper_config matches 2.. if score #rail_gap helper_config matches 1..32 run scoreboard players operation #rail_period helper_config = #rail_gap helper_config
scoreboard players set #rail_gap helper_config 0
