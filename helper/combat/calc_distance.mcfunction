# Calculate distance between helper and threat using scoreboard arithmetic
# This is a simplified placeholder - actual distance calc requires complex math

# For now, use entity selector distance instead
execute store result score #dist helper_combat run data get entity @e[type=#minecraft:hostile,distance=..24,sort=nearest,limit=1] Pos[0]
