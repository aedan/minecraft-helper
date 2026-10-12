scoreboard players set @s helper_q1 0
scoreboard players set @s helper_q2 0
scoreboard players set @s helper_q3 0
scoreboard players set @s helper_stay 1
scoreboard players set @s helper_mode 1
execute if score @s helper_job matches 11 run function helper:jobs/hunt_cleanup
function helper:jobs/clear_work
execute at @s run function helper:jobs/mark_here_as_base
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Stopped by you.","color":"yellow"}]
function helper:jobs/done
