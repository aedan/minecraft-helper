# Check for chest access within base area
# If an unknown (trust_level=1) opens a chest, they become a foe (trust_level=0) and get killed

# Simplified: check if any player with tag helper.unknown_in_base is near a chest
execute as @a[tag=helper.unknown_in_base] at @s run function helper:trust/check_near_chest
