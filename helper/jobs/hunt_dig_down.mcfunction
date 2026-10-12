# TARGETED DIG ONLY: close range + hunt target beneath us + no passageway.
# Clears a full 1x3 body corridor DOWN before moving. Never blind wall-tunnel.

execute unless entity @a[tag=helper.hunt_target,distance=..32,limit=1] run return 0

execute store result score #ty helper_config run data get entity @a[tag=helper.hunt_target,limit=1] Pos[1]
execute store result score #hy helper_config run data get entity @s Pos[1]
scoreboard players operation #dy helper_config = #ty helper_config
scoreboard players operation #dy helper_config -= #hy helper_config
# Target must be at least 2 blocks below
execute unless score #dy helper_config matches ..-2 run return 0

# Carve feet-below, then ensure headroom column stays clear ( ~ ~ ~ and ~ ~1 ~ after step)
execute at @s unless block ~ ~-1 ~ minecraft:bedrock unless block ~ ~-1 ~ minecraft:barrier unless block ~ ~-1 ~ #helper:passable run setblock ~ ~-1 ~ air destroy
execute at @s unless block ~ ~ ~ minecraft:bedrock unless block ~ ~ ~ minecraft:barrier unless block ~ ~ ~ #helper:passable run setblock ~ ~ ~ air destroy
execute at @s unless block ~ ~1 ~ minecraft:bedrock unless block ~ ~1 ~ minecraft:barrier unless block ~ ~1 ~ #helper:passable run setblock ~ ~1 ~ air destroy

# Move down ONLY after the space we will occupy is passable
execute at @s if block ~ ~-1 ~ #helper:passable if block ~ ~ ~ #helper:passable run tp @s ~ ~-1 ~

# Sweep drops + unstuck
execute as @e[type=item,distance=..2.5] run tp @s @e[tag=helper.self,limit=1]
function helper:jobs/hunt_unstuck
scoreboard players set @s helper_hunt_mode 2
