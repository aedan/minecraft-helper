# Check if this player is near a chest (within 4 blocks)
# If so, mark as foe and kill them

# Check for chest within 4 blocks
execute if block ~ ~ ~ minecraft:chest run function helper:trust/make_foe
execute if block ~1 ~ ~ minecraft:chest run function helper:trust/make_foe
execute if block ~-1 ~ ~ minecraft:chest run function helper:trust/make_foe
execute if block ~ ~ ~1 minecraft:chest run function helper:trust/make_foe
execute if block ~ ~ ~-1 minecraft:chest run function helper:trust/make_foe
execute if block ~ ~ ~ minecraft:barrel run function helper:trust/make_foe
execute if block ~1 ~ ~ minecraft:barrel run function helper:trust/make_foe
execute if block ~-1 ~ ~ minecraft:barrel run function helper:trust/make_foe
execute if block ~ ~ ~1 minecraft:barrel run function helper:trust/make_foe
execute if block ~ ~ ~-1 minecraft:barrel run function helper:trust/make_foe

# Remove unknown tag after check (so they don't re-trigger)
tag @s remove helper.unknown_in_base
