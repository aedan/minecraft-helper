# Intelligent mining system: locate ore, use correct tool, repair walls
# Tools: pickaxe for stone/ore, shovel for dirt/gravel, axe for wood

# Check what we're mining
execute if block ~ ~ ~ minecraft:stone run function helper:mine/use_pickaxe
execute if block ~ ~ ~ minecraft:dirt run function helper:mine/use_shovel
execute if block ~ ~ ~ minecraft:gravel run function helper:mine/use_shovel
execute if block ~ ~ ~ minecraft:oak_log run function helper:mine/use_axe
execute if block ~ ~ ~ minecraft:spruce_log run function helper:mine/use_axe
execute if block ~ ~ ~ minecraft:birch_log run function helper:mine/use_axe
execute if block ~ ~ ~ minecraft:iron_ore run function helper:mine/use_pickaxe
execute if block ~ ~ ~ minecraft:gold_ore run function helper:mine/use_pickaxe
execute if block ~ ~ ~ minecraft:diamond_ore run function helper:mine/use_pickaxe
execute if block ~ ~ ~ minecraft:coal_ore run function helper:mine/use_pickaxe
execute if block ~ ~ ~ minecraft:redstone_ore run function helper:mine/use_pickaxe
execute if block ~ ~ ~ minecraft:lapis_ore run function helper:mine/use_pickaxe
execute if block ~ ~ ~ minecraft:copper_ore run function helper:mine/use_pickaxe

# After mining, check if we broke a wall (block behind is air)
execute as @e[tag=helper.active,limit=1] at @s run function helper:mine/check_wall_break
