# Cut tree: completely fell the tree, collect all logs, replant

# Simplified: break all logs in a 5x10x5 area around the tree
# Use axe for logs, shovel for dirt/leaves

# Break logs (use axe)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:tree/break_logs

# Break leaves (simplified: just clear them)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:tree/break_leaves

# Replant tree
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:tree/replant

# Collect wood (simplified: give 16 logs)
execute as @e[type=villager,tag=helper.active,limit=1] run item give @s minecraft:oak_log 16

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Tree felled and replanted. ","color":"green"},{"text":"16 logs collected.","color":"gray"}]
playsound minecraft:block.oak_wood.break master @a[limit=1]
