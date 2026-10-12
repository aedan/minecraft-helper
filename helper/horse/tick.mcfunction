# Owner-follow horse: mount when owner rides, despawn when owner is on foot.
# Hunt (job 11) owns its own travel-mount lifecycle — never despawn/respawn here.

execute if score @s helper_job matches 11 run return 0

scoreboard players set #has_horse helper_config 0
execute as @e[type=horse,tag=helper.horse] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run scoreboard players set #has_horse helper_config 1

execute if score @s helper_owner_mounted matches 1 if score @s helper_on_horse matches 0 run function helper:horse/ensure
execute if score @s helper_owner_mounted matches 0 if score #has_horse helper_config matches 1 run function helper:horse/despawn_horse
