# Chase owner: teleport toward the player if they're more than 4 blocks away

# Get player position
execute as @a[limit=1] run scoreboard players set #chase_x helper_config < #x
execute as @a[limit=1] run scoreboard players set #chase_y helper_config < #y
execute as @a[limit=1] run scoreboard players set #chase_z helper_config < #z

# Teleport helper toward player (simplified: just move 2 blocks closer)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run tp @s ^2 ^ ^2

# Play chase sound
execute as @e[type=villager,tag=helper.active,limit=1] at @s run playsound minecraft:entity.enderman.teleport master @s
