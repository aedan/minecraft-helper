# Positioned on one lane cell, helper facing still applies to carets.
# Fill only a real gap: passable, solid floor, not fluid, and rails both behind and ahead
# within 8 blocks (so we do not extend the tip into empty tunnel).
execute unless block ~ ~ ~ #helper:passable run return 0
execute if block ~ ~ ~ minecraft:water run return 0
execute if block ~ ~ ~ minecraft:lava run return 0
execute if block ~ ~-1 ~ #helper:passable run return 0
execute if block ~ ~ ~ #minecraft:rails run return 0
scoreboard players set #gap_back helper_config 0
scoreboard players set #gap_fore helper_config 0
execute if block ^ ^ ^-1 #minecraft:rails run scoreboard players set #gap_back helper_config 1
execute if block ^ ^ ^1 #minecraft:rails run scoreboard players set #gap_fore helper_config 1
execute if block ^ ^ ^-2 #minecraft:rails run scoreboard players set #gap_back helper_config 1
execute if block ^ ^ ^2 #minecraft:rails run scoreboard players set #gap_fore helper_config 1
execute if block ^ ^ ^-3 #minecraft:rails run scoreboard players set #gap_back helper_config 1
execute if block ^ ^ ^3 #minecraft:rails run scoreboard players set #gap_fore helper_config 1
execute if block ^ ^ ^-4 #minecraft:rails run scoreboard players set #gap_back helper_config 1
execute if block ^ ^ ^4 #minecraft:rails run scoreboard players set #gap_fore helper_config 1
execute if block ^ ^ ^-5 #minecraft:rails run scoreboard players set #gap_back helper_config 1
execute if block ^ ^ ^5 #minecraft:rails run scoreboard players set #gap_fore helper_config 1
execute if block ^ ^ ^-6 #minecraft:rails run scoreboard players set #gap_back helper_config 1
execute if block ^ ^ ^6 #minecraft:rails run scoreboard players set #gap_fore helper_config 1
execute if block ^ ^ ^-7 #minecraft:rails run scoreboard players set #gap_back helper_config 1
execute if block ^ ^ ^7 #minecraft:rails run scoreboard players set #gap_fore helper_config 1
execute if block ^ ^ ^-8 #minecraft:rails run scoreboard players set #gap_back helper_config 1
execute if block ^ ^ ^8 #minecraft:rails run scoreboard players set #gap_fore helper_config 1
execute unless score #gap_back helper_config matches 1 run return 0
execute unless score #gap_fore helper_config matches 1 run return 0
function helper:jobs/lay_rails_place
