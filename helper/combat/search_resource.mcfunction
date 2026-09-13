# Search for resource: actively wander to find the target item

# Get fetch target from scoreboard (placeholder: always search for diamond ore)
execute if score #fetch_target helper_config matches 1.. run function helper:combat/search_diamond

# Simplified: just wander randomly and check for item entities
execute as @e[type=villager,tag=helper.active,limit=1] at @s run tp @s ^2 ^ ^2
execute as @e[type=villager,tag=helper.active,limit=1] at @s run playsound minecraft:block.amethyst_block.chime master @s
