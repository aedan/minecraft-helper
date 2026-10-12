# Helper found during recall/recover.
tag @s add helper.cmd
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id at @s run function helper:chunk/force_here

# Player-requested come-here: teleport + Watch Back.
execute if entity @s[tag=helper.recall_tp] as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set @s helper_mode 3
execute if entity @s[tag=helper.recall_tp] as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set @s helper_job 0
execute if entity @s[tag=helper.recall_tp] as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id at @a[tag=helper.cmd,limit=1] run tp @s ^1.2 ^ ^-0.8
execute if entity @s[tag=helper.recall_tp] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Coming to you.","color":"green"}]

scoreboard players set @s helper_recall 0
scoreboard players set @s helper_missing 0
tag @s remove helper.recall_tp
tag @s remove helper.cmd
