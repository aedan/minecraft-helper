# Sample rails/torch at current positioned spot. Prefer feet-level, else one below.
# Left
scoreboard players set #rail_cell helper_config 0
execute if block ^-1 ^ ^ #minecraft:rails run scoreboard players set #rail_cell helper_config 1
execute if score #rail_cell helper_config matches 0 if block ^-1 ^-1 ^ #minecraft:rails run scoreboard players set #rail_cell helper_config 2
execute if score #rail_cell helper_config matches 1.. run scoreboard players add #rail_L helper_config 1
execute if score #rail_cell helper_config matches 1 if block ^-1 ^ ^ minecraft:powered_rail run function helper:jobs/rail_learn_hit_powered
execute if score #rail_cell helper_config matches 2 if block ^-1 ^-1 ^ minecraft:powered_rail run function helper:jobs/rail_learn_hit_powered
execute if score #rail_cell helper_config matches 1 if block ^-1 ^ ^ minecraft:rail run scoreboard players add #rail_gap helper_config 1
execute if score #rail_cell helper_config matches 2 if block ^-1 ^-1 ^ minecraft:rail run scoreboard players add #rail_gap helper_config 1

# Center (only count presence; gap tracked on left preferentially, else right/center below)
scoreboard players set #rail_cell helper_config 0
execute if block ~ ~ ~ #minecraft:rails run scoreboard players set #rail_cell helper_config 1
execute if score #rail_cell helper_config matches 0 if block ~ ~-1 ~ #minecraft:rails run scoreboard players set #rail_cell helper_config 2
execute if score #rail_cell helper_config matches 1.. run scoreboard players add #rail_C helper_config 1

# Right
scoreboard players set #rail_cell helper_config 0
execute if block ^1 ^ ^ #minecraft:rails run scoreboard players set #rail_cell helper_config 1
execute if score #rail_cell helper_config matches 0 if block ^1 ^-1 ^ #minecraft:rails run scoreboard players set #rail_cell helper_config 2
execute if score #rail_cell helper_config matches 1.. run scoreboard players add #rail_R helper_config 1
# If left never contributed a powered gap this scan wave, allow right to seed period
execute if score #rail_pow helper_config matches 0 if score #rail_cell helper_config matches 1 if block ^1 ^ ^ minecraft:powered_rail run function helper:jobs/rail_learn_hit_powered
execute if score #rail_pow helper_config matches 0 if score #rail_cell helper_config matches 2 if block ^1 ^-1 ^ minecraft:powered_rail run function helper:jobs/rail_learn_hit_powered
execute if score #rail_L helper_config matches 0 if score #rail_cell helper_config matches 1 if block ^1 ^ ^ minecraft:rail run scoreboard players add #rail_gap helper_config 1
execute if score #rail_L helper_config matches 0 if score #rail_cell helper_config matches 2 if block ^1 ^-1 ^ minecraft:rail run scoreboard players add #rail_gap helper_config 1

# Torch offsets — CENTER (floor between dual lanes) vs WALL/OUTER (never conflate)
# Center floor / between lanes
execute if block ~ ~ ~ minecraft:redstone_torch run scoreboard players set #rail_torch_c helper_config 1
execute if block ~ ~-1 ~ minecraft:redstone_torch run scoreboard players set #rail_torch_c helper_config 1
# Wall / outer / above-rail (side of tunnel)
execute if block ^-2 ^ ^ minecraft:redstone_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^-2 ^-1 ^ minecraft:redstone_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^2 ^ ^ minecraft:redstone_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^2 ^-1 ^ minecraft:redstone_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^-1 ^1 ^ minecraft:redstone_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^1 ^1 ^ minecraft:redstone_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^-2 ^ ^ minecraft:redstone_wall_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^2 ^ ^ minecraft:redstone_wall_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^-1 ^ ^ minecraft:redstone_wall_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^1 ^ ^ minecraft:redstone_wall_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^-1 ^1 ^ minecraft:redstone_wall_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ^1 ^1 ^ minecraft:redstone_wall_torch run scoreboard players set #rail_torch_w helper_config 1
execute if block ~ ~1 ~ minecraft:redstone_wall_torch run scoreboard players set #rail_torch_w helper_config 1
