# Generic gather job (wood/ores/food). helper_gtype selects the resource.
execute if score @s helper_gtype matches 12 run function helper:jobs/hunt_tick
execute if score @s helper_gtype matches 12 run return 0
function helper:jobs/gather_equip_tool
execute unless entity @s[tag=helper.cut_announced] run function helper:jobs/gather_announce
tag @s add helper.cut_announced
function helper:jobs/vacuum_logs

execute if score @s helper_wood matches 2304.. run tag @s add helper.returning
execute if entity @s[tag=helper.returning] run function helper:jobs/return_home
execute if entity @s[tag=helper.returning] run return 0

scoreboard players add @s helper_work_cd 1
execute if score @s helper_work_cd matches 8.. run function helper:jobs/tree_scan
execute if score @s helper_work_cd matches 8.. run function helper:jobs/scan_far
execute if score @s helper_work_cd matches 8.. run scoreboard players set @s helper_work_cd 0

tag @e[tag=helper.dest] remove helper.dest
execute as @e[type=marker,tag=helper.tree] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.dest

execute if entity @e[tag=helper.dest,limit=1] run scoreboard players set @s helper_no_tree 0
execute unless entity @e[tag=helper.dest,limit=1] run scoreboard players add @s helper_no_tree 1

execute unless entity @e[tag=helper.dest,limit=1] if score @s helper_gtype matches 2..11 run function helper:jobs/dig_down
execute unless entity @e[tag=helper.dest,limit=1] run function helper:jobs/wander_search

execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 1.. run tag @s add helper.returning
execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 1.. run function helper:jobs/return_home
execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 0 run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Could not find any more of that.","color":"gray"}]
execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 0 run function helper:jobs/clear_work
execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 0 run function helper:jobs/done
execute if score @s helper_no_tree matches 600.. run return 0

execute if entity @e[tag=helper.dest,distance=..2.6,limit=1] run function helper:jobs/fell_tree
execute if entity @e[tag=helper.dest,distance=2.7..,limit=1] run function helper:jobs/go_to_dest
tag @e[tag=helper.dest] remove helper.dest
