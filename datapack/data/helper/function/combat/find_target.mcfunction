# Find the nearest hostile target and lock onto it

# Select nearest hostile mob within 24 blocks
execute as @e[tag=helper.active,limit=1] at @s run tag @e[tag=helper.enemy,distance=..24,sort=nearest,limit=1] add helper.targeted

# If owner is in danger (hostile within 16 blocks of player), prioritize protecting owner
execute if entity @a[limit=1] if entity @e[tag=helper.enemy,distance=..16,sort=nearest,limit=1] run function helper:combat/defend_owner
execute unless entity @e[tag=helper.enemy,distance=..16,sort=nearest,limit=1] run function helper:combat/engage_target
