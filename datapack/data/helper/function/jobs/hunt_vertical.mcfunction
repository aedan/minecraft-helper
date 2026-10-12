# Climb/descend toward hunt target. No horizontal wall dig. Down-dig only via hunt_dig_down.
execute unless entity @a[tag=helper.hunt_target,limit=1] run return 0
execute store result score #ty helper_config run data get entity @a[tag=helper.hunt_target,limit=1] Pos[1]
execute store result score #hy helper_config run data get entity @s Pos[1]
scoreboard players operation #dy helper_config = #ty helper_config
scoreboard players operation #dy helper_config -= #hy helper_config
execute if score #dy helper_config matches 3.. at @s unless block ~ ~2 ~ minecraft:bedrock unless block ~ ~2 ~ minecraft:barrier unless block ~ ~2 ~ #helper:passable run setblock ~ ~2 ~ air destroy
execute if score #dy helper_config matches 3.. at @s if block ~ ~1 ~ #helper:passable if block ~ ~2 ~ #helper:passable run tp @s ~ ~1 ~
execute if score #dy helper_config matches ..-3 if entity @a[tag=helper.hunt_target,distance=..32,limit=1] run function helper:jobs/hunt_dig_down
