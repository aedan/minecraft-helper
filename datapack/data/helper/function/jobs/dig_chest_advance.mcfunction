# Current chest is full. Leave it and mark a neighbor at the same feet level.
# Never one block up (unreachable ceiling of a 2-tall tunnel).
tag @e[type=marker,tag=helper.dig_chest,limit=1] add helper.dig_chest_old
execute at @e[type=marker,tag=helper.dig_chest_old,limit=1] positioned ~1 ~ ~ align xyz run function helper:jobs/dig_chest_try
execute unless entity @e[type=marker,tag=helper.dig_chest,tag=!helper.dig_chest_old,limit=1] at @e[type=marker,tag=helper.dig_chest_old,limit=1] positioned ~-1 ~ ~ align xyz run function helper:jobs/dig_chest_try
execute unless entity @e[type=marker,tag=helper.dig_chest,tag=!helper.dig_chest_old,limit=1] at @e[type=marker,tag=helper.dig_chest_old,limit=1] positioned ~ ~ ~1 align xyz run function helper:jobs/dig_chest_try
execute unless entity @e[type=marker,tag=helper.dig_chest,tag=!helper.dig_chest_old,limit=1] at @e[type=marker,tag=helper.dig_chest_old,limit=1] positioned ~ ~ ~-1 align xyz run function helper:jobs/dig_chest_try
execute unless entity @e[type=marker,tag=helper.dig_chest,tag=!helper.dig_chest_old,limit=1] at @e[type=marker,tag=helper.dig_chest_old,limit=1] positioned ~1 ~ ~-1 align xyz run function helper:jobs/dig_chest_try
execute unless entity @e[type=marker,tag=helper.dig_chest,tag=!helper.dig_chest_old,limit=1] at @e[type=marker,tag=helper.dig_chest_old,limit=1] positioned ~-1 ~ ~-1 align xyz run function helper:jobs/dig_chest_try
execute unless entity @e[type=marker,tag=helper.dig_chest,tag=!helper.dig_chest_old,limit=1] run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Chest is full and there is no open spot for another.","color":"yellow"}]
execute if entity @e[type=marker,tag=helper.dig_chest,tag=!helper.dig_chest_old,limit=1] run tag @e[type=marker,tag=helper.dig_chest_old] remove helper.dig_chest
kill @e[type=marker,tag=helper.dig_chest_old]
