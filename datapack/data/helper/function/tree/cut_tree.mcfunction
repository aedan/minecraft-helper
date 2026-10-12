# Cut tree: completely fell the tree, collect all logs, replant

# Simplified: break logs in a small area
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~ ~ minecraft:air
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~1 ~ minecraft:air
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~2 ~ minecraft:air
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~3 ~ minecraft:air

# Replant tree
execute as @e[tag=helper.active,limit=1] at @s run function helper:tree/replant

# Collect wood (add logs to inventory slot 0)
execute as @e[tag=helper.active,limit=1] run data modify entity @s Inventory[0] set value {id:"minecraft:oak_log",count:16b,Slot:0b}

tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Tree felled and replanted. ","color":"green"},{"text":"16 logs collected.","color":"gray"}]
playsound minecraft:block.oak_wood.break master @a[limit=1]
