# Return to base: teleport helper to the base marker

# Ensure a base marker exists (placed at owner's position as base reference)
execute unless entity @e[type=marker,tag=helper.base,limit=1] run function helper:combat/place_base_marker

# Teleport helper to the base marker
execute if entity @e[type=marker,tag=helper.base,limit=1] run tp @e[tag=helper.active,limit=1] @e[type=marker,tag=helper.base,limit=1]

# Play return sound
execute as @e[tag=helper.active,limit=1] at @s run playsound minecraft:entity.enderman.teleport master @s

# Organize chests after returning
execute if entity @e[type=marker,tag=helper.base,limit=1] at @e[type=marker,tag=helper.base,limit=1] run function helper:chest/organize

# Notify player
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Returned to base and organized supplies.","color":"green"}]
