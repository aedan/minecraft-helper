# Search for diamond ore: check for exposed diamond ore blocks nearby

# Check for diamond ore within 8 blocks
execute if block ~ ~ ~ minecraft:diamond_ore run function helper:combat/mine_diamond
execute if block ~1 ~ ~ minecraft:diamond_ore run function helper:combat/mine_diamond
execute if block ~-1 ~ ~ minecraft:diamond_ore run function helper:combat/mine_diamond
execute if block ~ ~ ~1 minecraft:diamond_ore run function helper:combat/mine_diamond
execute if block ~ ~ ~-1 minecraft:diamond_ore run function helper:combat/mine_diamond

# If not found, keep searching
execute unless block ~ ~ ~ minecraft:diamond_ore run function helper:combat/search_resource
