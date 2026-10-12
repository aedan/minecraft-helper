scoreboard players add #los_try helper_config 1
execute if score #los_try helper_config matches 8.. run return 0
tag @e[tag=helper.targeted] remove helper.targeted
function helper:combat/select_target
execute unless entity @e[tag=helper.targeted,limit=1] run return 0
function helper:combat/los_check
execute if score #los helper_config matches 1 run return 0
tag @e[tag=helper.targeted,limit=1] add helper.los_skip
tag @e[tag=helper.targeted] remove helper.targeted
function helper:combat/pick_seen_loop
