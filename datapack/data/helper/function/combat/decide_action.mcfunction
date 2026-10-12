# Decide what action the helper should take based on threat assessment and owner proximity

# Check for hostile mobs within detection range (24 blocks)
execute if entity @e[tag=helper.enemy,distance=..24,limit=1] run function helper:combat/find_target
execute unless entity @e[tag=helper.enemy,distance=..24,limit=1] run function helper:combat/idle_behavior
