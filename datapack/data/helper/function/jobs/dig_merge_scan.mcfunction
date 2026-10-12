scoreboard players set #i helper_config 0
function helper:jobs/dig_merge_step
execute if score #ins helper_config matches 0 run function helper:jobs/dig_insert_append
