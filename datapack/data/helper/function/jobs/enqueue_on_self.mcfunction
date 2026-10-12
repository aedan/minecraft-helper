execute if score @s helper_q1 matches 0 run return run function helper:jobs/set_q1
execute if score @s helper_q2 matches 0 run return run function helper:jobs/set_q2
execute if score @s helper_q3 matches 0 run return run function helper:jobs/set_q3
tellraw @a[tag=helper.cmd,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"My job list is full. Say stop, then try again.","color":"red"}]
