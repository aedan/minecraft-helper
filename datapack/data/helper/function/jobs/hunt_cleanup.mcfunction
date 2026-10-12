tag @a[tag=helper.hunt_target] remove helper.hunt_target
tag @a[tag=helper.priority_target] remove helper.priority_target
scoreboard players set @s helper_hunt_cd 0
scoreboard players set @s helper_hunt_miss 0
scoreboard players set @s helper_hunt_stuck 0
execute if score @s helper_on_horse matches 1 run function helper:horse/despawn_horse
execute unless score @s helper_on_horse matches 1 run function helper:jobs/hunt_cleanup_horse
function helper:jobs/hunt_cleanup_boats
function helper:jobs/hunt_cleanup_carts
