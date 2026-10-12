# Macro: run $(fn) as the helper owned by the player tagged helper.cmd
scoreboard players set #found helper_config 0
$execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id store success score #found helper_config run function $(fn)
execute if score #found helper_config matches 0 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You do not have a helper. ","color":"red"},{"text":"Build a golem or run /function helper:cmd_spawn","color":"gray"}]
