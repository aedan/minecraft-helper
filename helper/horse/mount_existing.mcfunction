tag @e[type=horse,tag=helper.my_horse] remove helper.my_horse
execute as @e[type=horse,tag=helper.horse] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_horse
ride @s mount @e[type=horse,tag=helper.my_horse,limit=1]
tag @e[type=horse,tag=helper.my_horse] remove helper.my_horse
scoreboard players set @s helper_on_horse 1
