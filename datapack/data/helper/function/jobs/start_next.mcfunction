scoreboard players operation @s helper_job = @s helper_q1
scoreboard players operation @s helper_gtype = @s helper_gt1
scoreboard players operation @s helper_q1 = @s helper_q2
scoreboard players operation @s helper_gt1 = @s helper_gt2
scoreboard players operation @s helper_q2 = @s helper_q3
scoreboard players operation @s helper_gt2 = @s helper_gt3
scoreboard players set @s helper_q3 0
scoreboard players set @s helper_gt3 0
execute if score @s helper_job matches 5 if score @s helper_gtype matches 0 run scoreboard players set @s helper_gtype 1
