# Find the attacker: check near the OWNER (not origin) for who hit them.
# Priority: hostile mobs near owner > other players near owner.
# Silent if nothing found (no spam).

# Hostile mob within 8 blocks of the owner -> engage it
execute as @a[limit=1] at @s if entity @e[tag=helper.enemy,distance=..8,sort=nearest,limit=1] run function helper:trust/attacker_found_hostile

# Other (non-friend) player within 8 blocks of the owner -> instant foe
execute as @a[limit=1] at @s unless entity @e[tag=helper.enemy,distance=..8,sort=nearest,limit=1] if entity @p[tag=!helper.friend,distance=..8,limit=1] run function helper:trust/attacker_found_player
