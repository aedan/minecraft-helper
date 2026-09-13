# Idle wait: stand still and look around

# No action needed, just idle
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data get entity @s Pos[0]
