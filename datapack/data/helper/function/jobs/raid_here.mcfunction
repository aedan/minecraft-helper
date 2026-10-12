execute unless entity @s[tag=helper.raid_set] run function helper:jobs/raid_start
tag @e[tag=helper.my_raid] remove helper.my_raid
execute as @e[type=marker,tag=helper.raid] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_raid

execute as @e[type=marker,tag=helper.my_raid,limit=1] at @s unless entity @e[type=#helper:raiders,distance=..32,limit=1] run scoreboard players add @e[tag=helper.self,limit=1] helper_raid_idle 1
execute as @e[type=marker,tag=helper.my_raid,limit=1] at @s if entity @e[type=#helper:raiders,distance=..32,limit=1] run scoreboard players set @e[tag=helper.self,limit=1] helper_raid_idle 0
execute if score @s helper_raid_idle matches 80.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Camp is clear.","color":"green"}]
execute if score @s helper_raid_idle matches 80.. run function helper:jobs/clear_work
execute if score @s helper_raid_idle matches 80.. run function helper:jobs/done
execute if score @s helper_raid_idle matches 80.. run return 0

tag @e[tag=helper.dest] remove helper.dest
tag @e[type=marker,tag=helper.my_raid,limit=1] add helper.dest
execute unless entity @e[tag=helper.targeted,limit=1] run function helper:jobs/go_to_dest
tag @e[tag=helper.dest] remove helper.dest
tag @e[type=marker,tag=helper.my_raid] remove helper.my_raid
