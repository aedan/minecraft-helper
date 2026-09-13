# Patrol base: wander within 16-block radius of base

# Randomly pick a new patrol point within 16 blocks
execute as @e[type=villager,tag=helper.active,limit=1] at @s run scoreboard players set #patrol_x helper_config < #x
execute as @e[type=villager,tag=helper.active,limit=1] at @s run scoreboard players set #patrol_y helper_config < #y
execute as @e[type=villager,tag=helper.active,limit=1] at @s run scoreboard players set #patrol_z helper_config < #z

# Offset by random amount (simplified: just move 2-4 blocks in random direction)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run tp @s ^2 ^ ^2
execute as @e[type=villager,tag=helper.active,limit=1] at @s run tp @s ^-2 ^ ^-2

# Play patrol sound
execute as @e[type=villager,tag=helper.active,limit=1] at @s run playsound minecraft:block.amethyst_block.chime master @s
