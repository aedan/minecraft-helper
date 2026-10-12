# Place rails on learned lanes at current position (helper facing). Solid support required.
# helper_gkind bitmask: 1=left 2=center 4=right. Does not advance phase.

# Left: kinds 1,3,5,7
execute if score @s helper_gkind matches 1 positioned ^-1 ^ ^ unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 3 positioned ^-1 ^ ^ unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 5 positioned ^-1 ^ ^ unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 7 positioned ^-1 ^ ^ unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place

# Center: kinds 2,3,6,7
execute if score @s helper_gkind matches 2 unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 3 unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 6 unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 7 unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place

# Right: kinds 4,5,6,7
execute if score @s helper_gkind matches 4 positioned ^1 ^ ^ unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 5 positioned ^1 ^ ^ unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 6 positioned ^1 ^ ^ unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place
execute if score @s helper_gkind matches 7 positioned ^1 ^ ^ unless block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run function helper:jobs/lay_rails_place

# Torches beside powered when this step is a powered step.
# helper_gt3: 1=center floor ONLY, 2=wall/outer ONLY, 3=both. Never invent walls for center-only.
scoreboard players set #rail_place_pow helper_config 0
execute if score @s helper_gt1 matches 1.. if score @s helper_gt2 >= @s helper_gt1 run scoreboard players set #rail_place_pow helper_config 1

# Wall/outer torches ONLY when observed (gt3 2 or 3)
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 2..3 if score @s helper_gkind matches 1 run function helper:jobs/lay_rails_torch_left
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 2..3 if score @s helper_gkind matches 3 run function helper:jobs/lay_rails_torch_left
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 2..3 if score @s helper_gkind matches 5 run function helper:jobs/lay_rails_torch_left
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 2..3 if score @s helper_gkind matches 7 run function helper:jobs/lay_rails_torch_left
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 2..3 if score @s helper_gkind matches 4 run function helper:jobs/lay_rails_torch_right
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 2..3 if score @s helper_gkind matches 5 run function helper:jobs/lay_rails_torch_right
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 2..3 if score @s helper_gkind matches 6 run function helper:jobs/lay_rails_torch_right
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 2..3 if score @s helper_gkind matches 7 run function helper:jobs/lay_rails_torch_right

# Center floor torch between dual lanes (gt3 1 or 3) — Jake sample
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 1 if score @s helper_gkind matches 5 run function helper:jobs/lay_rails_torch_center
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 1 if score @s helper_gkind matches 7 run function helper:jobs/lay_rails_torch_center
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 3 if score @s helper_gkind matches 5 run function helper:jobs/lay_rails_torch_center
execute if score #rail_place_pow helper_config matches 1 if score @s helper_gt3 matches 3 if score @s helper_gkind matches 7 run function helper:jobs/lay_rails_torch_center
