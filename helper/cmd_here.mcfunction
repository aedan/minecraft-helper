# Call the helper to the owner. Works even if the helper chunk was unloaded.
# /function helper:cmd_here   or   /trigger helper_cmd set 7
# Chat brain "come here" also routes here via jobs/bring_here.
function helper:id/assign
tag @s add helper.cmd
tag @s add helper.owner_tick
scoreboard players set @s helper_want 1
tag @s add helper.recall_tp

scoreboard players set #found helper_config 0
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set #found helper_config 1

execute if score #found helper_config matches 1 run function helper:lifecycle/recall_success
execute if score #found helper_config matches 1 run tag @s remove helper.owner_tick
execute if score #found helper_config matches 1 run tag @s remove helper.cmd
execute if score #found helper_config matches 1 run return 0

# Not loaded: start async forceload recall (owner_tick completes it).
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Looking for your helper…","color":"gray"}]
function helper:lifecycle/start_recover
tag @s remove helper.owner_tick
tag @s remove helper.cmd
