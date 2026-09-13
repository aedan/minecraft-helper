# Strafe: move perpendicular to target to avoid attacks while closing distance

# Calculate strafe direction (simplified: move left or right randomly)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data get entity @s Pos[0]

# Move helper in a strafe pattern
execute as @e[type=villager,tag=helper.active,limit=1] at @s run tp @s ^-0.5 ^ ^0.5
execute as @e[type=villager,tag=helper.active,limit=1] at @s run tp @s ^0.5 ^ ^-0.5

# Play movement sound
execute as @e[type=villager,tag=helper.active,limit=1] at @s run playsound minecraft:entity.villager.step master @s
