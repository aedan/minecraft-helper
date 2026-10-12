# Kill any horse still bound to this helper_id (travel leftover).
tag @e[type=horse,tag=helper.my_horse] remove helper.my_horse
execute as @e[type=horse,tag=helper.horse] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_horse
kill @e[type=horse,tag=helper.my_horse]
scoreboard players set @s helper_on_horse 0
