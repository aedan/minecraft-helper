execute at @e[tag=helper.dest,limit=1] run function helper:jobs/detect_wood
scoreboard players set #fell_n helper_config 0
execute if score @s helper_gtype matches 1 at @e[tag=helper.dest,limit=1] run function helper:jobs/fell_logs
execute if score @s helper_gtype matches 1 at @e[tag=helper.dest,limit=1] run function helper:jobs/strip_canopy
execute if score @s helper_gtype matches 1 at @e[tag=helper.dest,limit=1] run function helper:jobs/replant_stump
execute unless score @s helper_gtype matches 1 at @e[tag=helper.dest,limit=1] run function helper:jobs/break_vein
execute as @e[type=marker,tag=helper.tree] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run kill @s
function helper:jobs/vacuum_logs
playsound minecraft:block.wood.break master @a[distance=..16] ~ ~ ~ 1 1
