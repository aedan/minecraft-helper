# Check wall break: if we broke into a wall, repair it
# Simplified: check if the block we broke was part of a structure (surrounded by other blocks)
# If so, replace with the same block type

# For now, just replace with stone if it was stone
execute if block ~ ~ ~ minecraft:air if block ~-1 ~ ~ minecraft:stone run setblock ~ ~ ~ minecraft:stone
execute if block ~ ~ ~ minecraft:air if block ~1 ~ ~ minecraft:stone run setblock ~ ~ ~ minecraft:stone
execute if block ~ ~ ~ minecraft:air if block ~ ~-1 ~ minecraft:stone run setblock ~ ~ ~ minecraft:stone
execute if block ~ ~ ~ minecraft:air if block ~ ~1 ~ minecraft:stone run setblock ~ ~ ~ minecraft:stone

# If repaired, notify
execute if block ~ ~ ~ minecraft:stone run tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Wall repaired. ","color":"green"},{"text":"Replaced broken stone block.","color":"gray"}]
