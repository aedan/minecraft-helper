# Mine diamond: break the diamond ore block

# Break the block
execute as @e[type=villager,tag=helper.active,limit=1] at @s run setblock ~ ~ ~ minecraft:air

# Create diamond item
execute as @e[type=villager,tag=helper.active,limit=1] at @s run item replace entity @s inventory.mainhand with minecraft:diamond 1

# Play mining sound
execute as @e[type=villager,tag=helper.active,limit=1] at @s run playsound minecraft:block.diamond_ore.break master @s

# Return to base with diamond
function helper:combat/return_to_base
