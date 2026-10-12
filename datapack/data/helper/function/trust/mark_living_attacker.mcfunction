execute if entity @s[type=player,tag=helper.my_owner] run return 0
execute if entity @s[tag=helper.active] run return 0
execute if entity @s[type=player] run tag @s add helper.foe
# Combat tellraw removed — was spamming owner on HurtTime retriggers
tag @s add helper.targeted
tag @s add helper.priority_target
