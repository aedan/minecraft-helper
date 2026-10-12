# Choose the nearest threat that we can actually see. Skip mobs behind walls.
scoreboard players set #los_try helper_config 0
tag @e[tag=helper.los_skip] remove helper.los_skip
tag @e[tag=helper.targeted] remove helper.targeted
function helper:combat/pick_seen_loop
