# Defend owner: prioritize killing the threat closest to the player, maintain position between owner and threat

# Get player position
execute as @a[limit=1] run scoreboard players set #owner_x helper_combat < #x
execute as @a[limit=1] run scoreboard players set #owner_y helper_combat < #y
execute as @a[limit=1] run scoreboard players set #owner_z helper_combat < #z

# Get threat position (nearest hostile to player)
execute as @e[type=#minecraft:hostile,distance=..16,sort=nearest,limit=1] run scoreboard players set #threat_x helper_combat < #x
execute as @e[type=#minecraft:hostile,distance=..16,sort=nearest,limit=1] run scoreboard players set #threat_y helper_combat < #y
execute as @e[type=#minecraft:hostile,distance=..16,sort=nearest,limit=1] run scoreboard players set #threat_z helper_combat < #z

# Calculate distance to threat
execute store result score #dist helper_combat run function helper:combat/calc_distance

# If threat is within sword range (3 blocks), engage with sword
execute if score #dist helper_combat matches ..3 run function helper:combat/sword_attack
# If threat is within bow range (12-24 blocks), shoot with bow
execute if score #dist helper_combat matches 12..24 run function helper:combat/bow_attack
# Otherwise, strafe to get into position
execute if score #dist helper_combat matches 4..11 run function helper:combat/strafe
