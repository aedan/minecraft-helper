# Caller has decided feet are in a full solid. Step to the nearest 2-tall air.
# Stop as soon as the feet block is passable (air / water / replaceable).
execute positioned ~ ~1 ~ if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~1 ~ ~ if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~-1 ~ ~ if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~ ~ ~1 if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~ ~ ~-1 if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~ ~2 ~ if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~1 ~1 ~ if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~-1 ~1 ~ if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~ ~1 ~1 if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~ ~1 ~-1 if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
execute at @s if block ~ ~ ~ #helper:passable run return 0
execute positioned ~ ~3 ~ if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run tp @s ~ ~ ~
