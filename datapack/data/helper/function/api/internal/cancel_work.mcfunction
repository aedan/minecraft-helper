# As a helper. Cancel the current job and queue without touching mode switches.
execute if score @s helper_job matches 11 run function helper:jobs/hunt_cleanup
function helper:jobs/clear_work
scoreboard players set @s helper_q1 0
scoreboard players set @s helper_q2 0
scoreboard players set @s helper_q3 0
scoreboard players set @s helper_job 0
tag @s remove helper.preempted
tag @s remove helper.defending
