# Use pickaxe: mine stone/ore blocks
# Simplified: just break the block

execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~ ~ ~ minecraft:air
playsound minecraft:block.stone.break master @a[limit=1]
