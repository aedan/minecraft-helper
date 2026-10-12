execute as @e[type=marker,tag=helper.raid] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run kill @s
execute as @a[tag=helper.my_owner,limit=1] at @s run summon marker ~ ~ ~ {Tags:["helper.raid","helper.raid_new"],PersistenceRequired:1b}
scoreboard players operation @e[type=marker,tag=helper.raid_new,limit=1] helper_id = @s helper_id
tag @e[type=marker,tag=helper.raid_new] remove helper.raid_new
tag @s add helper.raid_set
scoreboard players set @s helper_raid_idle 0
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Going after pillagers at your position.","color":"red"}]
