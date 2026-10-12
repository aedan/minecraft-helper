# As the owner. Claim/teleport helper here, or start async recover if unloaded/dead.
function helper:id/assign
tag @s add helper.cmd
tag @s add helper.owner_tick
scoreboard players set @s helper_want 1
tag @s add helper.recall_tp

execute as @e[type=minecraft:mannequin] run tag @s add helper.active

scoreboard players set #found helper_config 0
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set #found helper_config 1

# If no id-matched helper but some helper exists nearby, claim nearest.
execute if score #found helper_config matches 0 as @e[tag=helper.active,sort=nearest,limit=1] run scoreboard players operation @s helper_id = @a[tag=helper.cmd,limit=1] helper_id
execute if score #found helper_config matches 0 as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set #found helper_config 1

execute if score #found helper_config matches 1 run function helper:lifecycle/recall_success
execute if score #found helper_config matches 1 run tag @s remove helper.owner_tick
execute if score #found helper_config matches 1 run tag @s remove helper.cmd
execute if score #found helper_config matches 1 run return 0

# Unloaded or dead: async forceload then respawn via lifecycle.
function helper:jobs/bring_unloaded
tag @s remove helper.owner_tick
tag @s remove helper.cmd
