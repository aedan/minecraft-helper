# Engage target: tag nearest hostile, move adjacent, attack.
# NoAI zombie can't pathfind, so we snap it next to the target and strike.

# Tag the nearest hostile as targeted
execute as @e[tag=helper.active,limit=1] at @s run tag @e[tag=helper.enemy,distance=..24,sort=nearest,limit=1] add helper.targeted

# Preemptive bow shot if target is far (12-24 blocks)
execute as @e[tag=helper.active,limit=1] at @s if entity @e[tag=helper.enemy,distance=12..24,limit=1] run function helper:combat/bow_attack

# Move adjacent to the target (within 4-block sword range)
execute as @e[tag=helper.active,limit=1] at @s if entity @e[tag=helper.enemy,limit=1] run function helper:combat/approach_target

# Sword strike now that we're adjacent
execute as @e[tag=helper.active,limit=1] at @s if entity @e[tag=helper.enemy,distance=..5,limit=1] run function helper:combat/sword_attack
