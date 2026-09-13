# Find the nearest hostile target and lock onto it

# Select nearest hostile mob within 24 blocks
execute as @e[type=villager,tag=helper.active,limit=1] run scoreboard players set #target_id helper_combat < @e[type=#minecraft:hostile,distance=..24,tag=!helper.ignored,sort=nearest,limit=1]

# If owner is in danger (hostile within 16 blocks of player), prioritize protecting owner
execute if entity @a[limit=1] if entity @e[type=#minecraft:hostile,distance=..16,sort=nearest,limit=1] run function helper:combat/defend_owner
execute unless entity @e[type=#minecraft:hostile,distance=..16,sort=nearest,limit=1] run function helper:combat/engage_target
