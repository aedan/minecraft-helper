# Find the attacker: check nearby entities that could have dealt damage
# Priority: players > hostile mobs > other entities

# Check for nearby players (within 8 blocks) who aren't the owner
execute as @a[tag=!helper.friend,distance=..8,limit=1] at @s run function helper:trust/attacker_found_player

# Check for hostile mobs (within 8 blocks)
execute unless entity @a[tag=!helper.friend,distance=..8,limit=1] as @e[type=#minecraft:hostile,distance=..8,sort=nearest,limit=1] at @s run function helper:trust/attacker_found_hostile

# Check for other damage sources (skeleton arrows, etc.)
execute unless entity @a[tag=!helper.friend,distance=..8,limit=1] unless entity @e[type=#minecraft:hostile,distance=..8,sort=nearest,limit=1] as @e[type=item,distance=..4,limit=1] at @s run function helper:trust/attacker_unknown
