# Check perimeter for unknowns (trust_level not set or = 0)
# If unknown enters 16-block radius, mark as "unknown_in_base"

# Find players without trust_level set within 16 blocks of base
execute as @a[tag=!helper.friend,distance=..16] run scoreboard players set @s trust_level 1
execute as @a[tag=!helper.friend,distance=..16] run tag @s add helper.unknown_in_base

# Find hostiles within 24 blocks of base
execute if entity @e[type=#minecraft:hostile,distance=..24] run function helper:trust/engage_hostile
