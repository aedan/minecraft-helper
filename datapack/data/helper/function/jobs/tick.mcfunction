# Instant jobs (1-4). Long jobs (5-12) run from helper_tick after combat.
execute if score @s helper_job matches 0 if score @s helper_q1 matches 1.. run function helper:jobs/start_next
execute if score @s helper_job matches 1 run function helper:jobs/come_here
execute if score @s helper_job matches 2 run function helper:jobs/stay_home
execute if score @s helper_job matches 3 run function helper:jobs/stop
execute if score @s helper_job matches 4 run function helper:jobs/set_base
