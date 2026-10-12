# Chase owner: only called when owner is >4 blocks away and NOT fighting.
# Repositions the helper to the guard offset (2 blocks beside owner).

execute as @a[limit=1] at @s run function helper:combat/guard_position
