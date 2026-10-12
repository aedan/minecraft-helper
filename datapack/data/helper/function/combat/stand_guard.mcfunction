# Stand guard: hold position beside owner at a FIXED world offset (not facing-relative)
# Place helper 2 blocks to the owner's +X, same Y, +Z 0 — independent of where the player looks.

# Get owner position, offset, and teleport helper to that absolute spot
execute as @a[limit=1] run function helper:combat/guard_position

# Check for threats within 16 blocks of the helper and engage
execute as @e[tag=helper.active,limit=1] if entity @e[tag=helper.enemy,distance=..16,limit=1] run function helper:combat/find_target
