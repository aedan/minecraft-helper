# Replant tree: place a sapling where the tree was cut

# Place oak sapling
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~ ~ ~ minecraft:oak_sapling

# Give sapling to player (optional)
execute as @e[type=villager,tag=helper.active,limit=1] run item give @a[limit=1] minecraft:oak_sapling 1

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Tree replanted. ","color":"green"},{"text":"Sapling placed at cut location.","color":"gray"}]
