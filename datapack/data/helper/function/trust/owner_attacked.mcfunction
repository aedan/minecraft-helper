# Owner was attacked: find who hit them and make them an instant foe
# Check for nearby players, hostile mobs, or other entities that could have dealt damage

# Check for nearby players who could have attacked (within 8 blocks, not the owner)
execute as @e[tag=helper.active,limit=1] at @s run function helper:trust/find_attacker
