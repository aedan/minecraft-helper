# Sets #feet_solid helper_config to 1 when the feet block is a full solid
# (bedrock, stone, …). Skips rails and other non-full blocks the helper stands in.
# Rails and torches are ignored so standing on a track does not count.
scoreboard players set #feet_solid helper_config 0
execute unless block ~ ~ ~ #helper:passable unless block ~ ~ ~ #minecraft:rails unless block ~ ~ ~ minecraft:torch unless block ~ ~ ~ minecraft:wall_torch unless block ~ ~ ~ minecraft:soul_torch unless block ~ ~ ~ minecraft:soul_wall_torch unless block ~ ~ ~ minecraft:redstone_torch unless block ~ ~ ~ minecraft:redstone_wall_torch unless block ~ ~ ~ minecraft:redstone_wire unless block ~ ~ ~ minecraft:chest unless block ~ ~ ~ minecraft:trapped_chest unless block ~ ~ ~ minecraft:ladder unless block ~ ~ ~ minecraft:vine unless block ~ ~ ~ minecraft:snow run scoreboard players set #feet_solid helper_config 1
