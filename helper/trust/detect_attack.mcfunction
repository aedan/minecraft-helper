# PVP/Attack detection: if owner gets hit, the attacker becomes an instant foe
# Runs every tick

# Check if owner took damage recently
# Using the "HurtTime" NBT field - if > 0, they were hit recently
execute as @a[tag=helper.friend,limit=1] if data entity @s HurtTime run function helper:trust/owner_attacked

# Also check if owner's health dropped (alternative detection)
# This catches cases where HurtTime might not be set
execute as @a[tag=helper.friend,limit=1] run scoreboard players get @s health
execute as @a[tag=helper.friend,limit=1] if score @s health < @s health_prev run function helper:trust/owner_attacked
