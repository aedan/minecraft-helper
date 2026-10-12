# Break logs: use axe to break all wood blocks in tree area
# Simplified: just break the bottom log

execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~ ~ minecraft:air
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~1 ~ minecraft:air
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~2 ~ minecraft:air
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~3 ~ minecraft:air
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~4 ~ minecraft:air

# Full implementation would scan the entire tree and break each log with axe
