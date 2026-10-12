# Recount phase at current helper position into helper_gt2.
# Requires helper_gkind already set; uses #rail_mask from gkind.
scoreboard players operation #rail_mask helper_config = @s helper_gkind
scoreboard players set #rail_phase helper_config 0
scoreboard players set #rail_scan helper_config 0
execute at @s run function helper:jobs/rail_learn_phase
execute if score @s helper_gt1 matches 1.. if score #rail_phase helper_config > @s helper_gt1 run scoreboard players operation #rail_phase helper_config = @s helper_gt1
scoreboard players operation @s helper_gt2 = #rail_phase helper_config
