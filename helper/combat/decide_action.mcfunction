# Decide what action the helper should take based on threat assessment and owner proximity

# Check for hostile mobs within detection range (24 blocks)
execute if entity @e[type=#minecraft:hostile,distance=..24,tag=!helper.ignored,limit=1] run function helper:combat/find_target
execute unless entity @e[type=#minecraft:hostile,distance=..24,tag=!helper.ignored,limit=1] run function helper:combat/idle_behavior
