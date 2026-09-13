# Attacker unknown: scan wider area for any hostile

# Check wider radius for hostiles
execute as @e[type=villager,tag=helper.active,limit=1] at @s unless entity @e[type=#minecraft:hostile,distance=..8,limit=1] if entity @e[type=#minecraft:hostile,distance=..16,limit=1] run function helper:trust/attacker_found_hostile

# If still nothing found, alert owner
execute as @e[type=villager,tag=helper.active,limit=1] at @s unless entity @e[type=#minecraft:hostile,distance=..16,limit=1] run tellraw @a[tag=helper.friend,limit=1] [{"text":"[DEFENSE] ","color":"yellow","bold":true"},{"text":"You were attacked! ","color":"white"},{"text":"Searching for the source...","color":"gray"}]
