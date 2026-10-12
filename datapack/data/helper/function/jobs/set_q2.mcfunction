scoreboard players operation @s helper_q2 = #job helper_config
scoreboard players operation @s helper_gt2 = #gtype helper_config
execute if score @s helper_q2 matches 5 if score @s helper_gt2 matches 0 run scoreboard players set @s helper_gt2 1
