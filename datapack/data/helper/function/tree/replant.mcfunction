# Replant tree: place a sapling where the tree was cut

# Place oak sapling
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~ ~ minecraft:oak_sapling

tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Tree replanted. ","color":"green"},{"text":"Sapling placed at cut location.","color":"gray"}]
