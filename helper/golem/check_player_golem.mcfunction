# Check for golem structure at player's position
# Pattern: 4 metal blocks in a square + pumpkin on top
# Player must be standing inside or adjacent to the structure

# Check for Tier 1: Stone Golem
execute if block ~ ~ ~ minecraft:stone if block ~1 ~ ~ minecraft:stone if block ~ ~ ~1 minecraft:stone if block ~1 ~ ~1 minecraft:stone if block ~ ~1 ~ minecraft:carved_pumpkin run function helper:golem/summon_tier1

# Check for Tier 2: Iron Golem
execute if block ~ ~ ~ minecraft:iron_block if block ~1 ~ ~ minecraft:iron_block if block ~ ~ ~1 minecraft:iron_block if block ~1 ~ ~1 minecraft:iron_block if block ~ ~1 ~ minecraft:carved_pumpkin run function helper:golem/summon_tier2

# Check for Tier 3: Netherite Golem (netherite blocks + pumpkin + diamond on top)
execute if block ~ ~ ~ minecraft:netherite_block if block ~1 ~ ~ minecraft:netherite_block if block ~ ~ ~1 minecraft:netherite_block if block ~1 ~ ~1 minecraft:netherite_block if block ~ ~1 ~ minecraft:carved_pumpkin if block ~ ~2 ~ minecraft:diamond_block run function helper:golem/summon_tier3
