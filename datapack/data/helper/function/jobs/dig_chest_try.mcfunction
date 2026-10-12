# Aligned to a candidate block corner. Place only if a player can open it:
# feet-level passable (not water/lava), solid floor, passable above, not inside the helper.
execute unless block ~ ~ ~ #helper:passable run return 0
execute if block ~ ~ ~ minecraft:water run return 0
execute if block ~ ~ ~ minecraft:lava run return 0
execute if block ~ ~-1 ~ #helper:passable run return 0
execute unless block ~ ~1 ~ #helper:passable run return 0
execute if block ~ ~-1 ~ minecraft:bedrock run return 0
execute positioned ~0.5 ~0.5 ~0.5 if entity @s[distance=..0.8] run return 0
function helper:jobs/dig_chest_put
