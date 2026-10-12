# If the owner just took damage, tag whoever hit them.
execute if score @s helper_atk_cd matches 1.. run return 0
execute as @a[tag=helper.my_owner,limit=1] store result score @s helper_hurt run data get entity @s HurtTime
execute as @a[tag=helper.my_owner,limit=1] if score @s helper_hurt matches 8.. on attacker run function helper:trust/mark_attacker
execute as @a[tag=helper.my_owner,limit=1] if score @s helper_hurt matches 8.. run scoreboard players set @e[tag=helper.self,limit=1] helper_atk_cd 15
