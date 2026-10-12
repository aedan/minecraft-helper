execute store result storage helper:tmp x int 1 run scoreboard players get @s helper_tx
execute store result storage helper:tmp y int 1 run scoreboard players get @s helper_ty
execute store result storage helper:tmp z int 1 run scoreboard players get @s helper_tz
function helper:jobs/hunt_goto_last with storage helper:tmp
