execute if score #found helper_config matches 1 run return 0
scoreboard players set #found helper_config 1
execute as @e[type=marker,tag=helper.tree] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run kill @s
summon marker ~ ~ ~ {Tags:["helper.tree","helper.tree_new"],PersistenceRequired:1b}
scoreboard players operation @e[type=marker,tag=helper.tree_new,limit=1] helper_id = @e[tag=helper.self,limit=1] helper_id
tag @e[type=marker,tag=helper.tree_new] remove helper.tree_new
