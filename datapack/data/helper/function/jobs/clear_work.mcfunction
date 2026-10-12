tag @s add helper.cleaner
tag @s remove helper.raid_set
tag @s remove helper.cut_announced
tag @s remove helper.chest_announced
tag @s remove helper.returning
tag @s remove helper.smelt_home
scoreboard players set @s helper_raid_idle 0
scoreboard players set @s helper_no_tree 0
scoreboard players set @s helper_work_cd 0
scoreboard players set @s helper_dig_left 0
scoreboard players set @s helper_hunt_cd 0
scoreboard players set @s helper_hunt_stuck 0
scoreboard players set @s helper_hunt_mode 0
execute as @e[type=marker,tag=helper.tree] if score @s helper_id = @e[tag=helper.cleaner,limit=1] helper_id run kill @s
execute as @e[type=marker,tag=helper.raid] if score @s helper_id = @e[tag=helper.cleaner,limit=1] helper_id run kill @s
tag @s remove helper.cleaner
