# Friend/foe detection system with trust levels
# Trust levels: 0 = foe, 1 = unknown, 2 = friend
# Friends: owner + whitelisted players
# Unknowns: anyone not identified
# Foes: hostiles + unknowns who touch chests

# On load, set owner as friend
execute as @a[limit=1] run scoreboard players set @s trust_level 2
execute as @a[limit=1] run tag @s add helper.friend

# Check for unknowns entering base perimeter (16 blocks)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:trust/check_perimeter

# Check for chest interaction (anyone opening a chest within base)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:trust/check_chest_access

# Hostiles approaching base = instant kill
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:trust/hostile_threat
