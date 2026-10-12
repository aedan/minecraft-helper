scoreboard players operation @s helper_q1 = #job helper_config
scoreboard players operation @s helper_gt1 = #gtype helper_config
execute if score @s helper_q1 matches 5 if score @s helper_gt1 matches 0 run scoreboard players set @s helper_gt1 1
