tag @e[type=marker,tag=helper.my_base] remove helper.my_base
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_base
