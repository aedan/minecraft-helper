execute if score #i helper_config matches 27.. run return 0
execute if score #ins helper_config matches 1 run return 0
execute store result storage helper:digdrop i int 1 run scoreboard players get #i helper_config
function helper:jobs/dig_merge_one with storage helper:digdrop
execute if score #ins helper_config matches 0 run scoreboard players add #i helper_config 1
execute if score #ins helper_config matches 0 run function helper:jobs/dig_merge_step
