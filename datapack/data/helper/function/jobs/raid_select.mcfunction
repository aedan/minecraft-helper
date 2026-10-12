tag @e[tag=helper.my_raid] remove helper.my_raid
execute as @e[type=marker,tag=helper.raid] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_raid
execute as @e[type=marker,tag=helper.my_raid,limit=1] at @s run tag @e[type=#helper:raiders,tag=!helper.los_skip,distance=..32,sort=nearest,limit=1] add helper.targeted
tag @e[type=marker,tag=helper.my_raid] remove helper.my_raid
