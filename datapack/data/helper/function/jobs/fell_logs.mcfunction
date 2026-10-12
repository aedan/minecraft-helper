# Flood-fill connected logs so the whole trunk and branches come down.
execute unless block ~ ~ ~ #minecraft:logs run return 0
execute if score #fell_n helper_config matches 96.. run return 0
scoreboard players add #fell_n helper_config 1
setblock ~ ~ ~ air destroy
execute positioned ~ ~1 ~ run function helper:jobs/fell_logs
execute positioned ~ ~-1 ~ run function helper:jobs/fell_logs
execute positioned ~1 ~ ~ run function helper:jobs/fell_logs
execute positioned ~-1 ~ ~ run function helper:jobs/fell_logs
execute positioned ~ ~ ~1 run function helper:jobs/fell_logs
execute positioned ~ ~ ~-1 run function helper:jobs/fell_logs
