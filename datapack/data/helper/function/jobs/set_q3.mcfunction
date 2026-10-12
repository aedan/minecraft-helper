scoreboard players operation @s helper_q3 = #job helper_config
scoreboard players operation @s helper_gt3 = #gtype helper_config
execute if score @s helper_q3 matches 5 if score @s helper_gt3 matches 0 run scoreboard players set @s helper_gt3 1
