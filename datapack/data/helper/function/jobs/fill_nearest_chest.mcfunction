execute unless score @s helper_wood matches 1.. run return 0
execute unless entity @e[type=marker,tag=helper.dest,limit=1] run return 0
execute at @e[tag=helper.dest,limit=1] positioned ~1 ~ ~ if block ~ ~ ~ minecraft:chest run function helper:jobs/dump_wood
execute at @e[tag=helper.dest,limit=1] positioned ~-1 ~ ~ if block ~ ~ ~ minecraft:chest run function helper:jobs/dump_wood
execute at @e[tag=helper.dest,limit=1] positioned ~ ~ ~1 if block ~ ~ ~ minecraft:chest run function helper:jobs/dump_wood
execute at @e[tag=helper.dest,limit=1] positioned ~ ~ ~-1 if block ~ ~ ~ minecraft:chest run function helper:jobs/dump_wood
execute at @e[tag=helper.dest,limit=1] if block ~ ~ ~ minecraft:chest run function helper:jobs/dump_wood
