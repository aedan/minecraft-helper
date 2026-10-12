function helper:jobs/clear_work
scoreboard players set @s helper_q1 0
scoreboard players set @s helper_q2 0
scoreboard players set @s helper_q3 0
scoreboard players operation @s helper_job = #job helper_config
scoreboard players operation @s helper_gtype = #gtype helper_config
execute if score @s helper_job matches 5 if score @s helper_gtype matches 0 run scoreboard players set @s helper_gtype 1
execute if score @s helper_job matches 1 run function helper:jobs/come_here
execute if score @s helper_job matches 2 run function helper:jobs/stay_home
execute if score @s helper_job matches 3 run function helper:jobs/stop
scoreboard players set #ok helper_config 1
