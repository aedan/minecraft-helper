$execute positioned $(x) $(y) $(z) run summon marker ~ ~ ~ {Tags:["helper.base","helper.base_new"],PersistenceRequired:1b}
execute as @e[type=marker,tag=helper.base_new,limit=1] run scoreboard players operation @s helper_id = @a[tag=helper.summoner,limit=1] helper_id
execute at @e[type=marker,tag=helper.base_new,limit=1] run forceload add ~ ~
tag @e[type=marker,tag=helper.base_new] remove helper.base_new
