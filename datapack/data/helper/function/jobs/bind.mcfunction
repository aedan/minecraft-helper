# As the commanding player (tagged helper.cmd). Attach a loaded helper to this player.
function helper:id/assign
scoreboard players set #found helper_config 0
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set #found helper_config 1
execute if score #found helper_config matches 0 as @e[tag=helper.active,sort=nearest,limit=1] run scoreboard players operation @s helper_id = @a[tag=helper.cmd,limit=1] helper_id
execute if score #found helper_config matches 0 if entity @e[tag=helper.active,limit=1] run scoreboard players set #found helper_config 1
