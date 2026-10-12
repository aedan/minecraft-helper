execute at @e[tag=helper.dest,limit=1] positioned ~1 ~ ~ if block ~ ~ ~ minecraft:air run setblock ~ ~ ~ minecraft:chest
execute at @e[tag=helper.dest,limit=1] positioned ~1 ~ ~ unless block ~ ~ ~ minecraft:chest positioned ~-1 ~ ~ if block ~ ~ ~ minecraft:air run setblock ~ ~ ~ minecraft:chest
execute at @e[tag=helper.dest,limit=1] positioned ~1 ~ ~ unless block ~ ~ ~ minecraft:chest positioned ~-1 ~ ~ unless block ~ ~ ~ minecraft:chest positioned ~ ~ ~1 if block ~ ~ ~ minecraft:air run setblock ~ ~ ~ minecraft:chest
execute at @e[tag=helper.dest,limit=1] positioned ~ ~ ~-1 if block ~ ~ ~ minecraft:air unless block ~1 ~ ~ minecraft:chest unless block ~-1 ~ ~ minecraft:chest unless block ~ ~ ~1 minecraft:chest run setblock ~ ~ ~ minecraft:chest
function helper:jobs/fill_nearest_chest
tag @s remove helper.chest_announced
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Chest is ready.","color":"green"}]
scoreboard players set @s helper_wood 0
function helper:jobs/done
