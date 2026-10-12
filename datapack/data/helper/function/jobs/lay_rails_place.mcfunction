# Place one rail cell at current position based on helper pattern phase.
# If helper_gt1 (period) > 0 and helper_gt2 >= helper_gt1 → powered_rail; else helper_gtype.
scoreboard players set #rail_place_pow helper_config 0
execute if score @s helper_gt1 matches 1.. if score @s helper_gt2 >= @s helper_gt1 run scoreboard players set #rail_place_pow helper_config 1

execute if score #rail_place_pow helper_config matches 1 run setblock ~ ~ ~ minecraft:powered_rail
execute if score #rail_place_pow helper_config matches 0 if score @s helper_gtype matches 0 run setblock ~ ~ ~ minecraft:rail
execute if score #rail_place_pow helper_config matches 0 if score @s helper_gtype matches 1 run setblock ~ ~ ~ minecraft:powered_rail
execute if score #rail_place_pow helper_config matches 0 if score @s helper_gtype matches 2 run setblock ~ ~ ~ minecraft:detector_rail
execute if score #rail_place_pow helper_config matches 0 if score @s helper_gtype matches 3 run setblock ~ ~ ~ minecraft:activator_rail
execute if score #rail_place_pow helper_config matches 0 unless score @s helper_gtype matches 0..3 run setblock ~ ~ ~ minecraft:rail
