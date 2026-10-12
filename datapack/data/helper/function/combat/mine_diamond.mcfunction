# Mine diamond: break the diamond ore block

# Break the block
execute as @e[tag=helper.active,limit=1] at @s run setblock ~ ~ ~ minecraft:air

# Add diamond to inventory slot 0
execute as @e[tag=helper.active,limit=1] run data modify entity @s Inventory[0] set value {id:"minecraft:diamond",count:1b,Slot:0b}

# Play mining sound
execute as @e[tag=helper.active,limit=1] at @s run playsound minecraft:block.diamond_ore.break master @s

# Return to base with diamond
function helper:combat/return_to_base
