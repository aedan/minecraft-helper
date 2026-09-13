# Stand guard: stay close to owner and watch for threats

# Check for threats within 8 blocks
execute if entity @e[type=#minecraft:hostile,distance=..8,limit=1] run function helper:combat/find_target

# If no threats, just idle
execute unless entity @e[type=#minecraft:hostile,distance=..8,limit=1] run function helper:combat/idle_wait
