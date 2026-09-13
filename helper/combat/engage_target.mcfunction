# Engage target directly: attack the locked-on hostile mob

# Get target position from scoreboard
execute store result entity @e[type=#minecraft:hostile,tag=helper.targeted,limit=1] Pos[0] double 1 run scoreboard players get #threat_x helper_combat
execute store result entity @e[type=#minecraft:hostile,tag=helper.targeted,limit=1] Pos[1] double 1 run scoreboard players get #threat_y helper_combat
execute store result entity @e[type=#minecraft:hostile,tag=helper.targeted,limit=1] Pos[2] double 1 run scoreboard players get #threat_z helper_combat

# Calculate distance to target
execute store result score #dist helper_combat run function helper:combat/calc_distance

# If target is within sword range, attack with sword
execute if score #dist helper_combat matches ..3 run function helper:combat/sword_attack
# If target is at bow range, shoot with bow
execute if score #dist helper_combat matches 12..24 run function helper:combat/bow_attack
# If in between, close distance with strafe
execute if score #dist helper_combat matches 4..11 run function helper:combat/strafe
