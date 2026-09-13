# Ore location system: scan for ore in a 32-block radius
# Reports what's found and where

# Scan for each ore type
execute store result score #iron_ore helper_config run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:iron_ore
execute store result score #gold_ore helper_config run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:gold_ore
execute store result score #diamond_ore helper_config run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:diamond_ore
execute store result score #coal_ore helper_config run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:coal_ore
execute store result score #redstone_ore helper_config run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:redstone_ore
execute store result score #lapis_ore helper_config run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:lapis_ore
execute store result score #copper_ore helper_config run test for blocks ~-32 ~-16 ~-32 ~32 ~16 ~32 minecraft:copper_ore

# Report findings
tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Ore scan complete:\n","color":"green"},{"text":"Iron: ","color":"gray"},{"text":"","color":"white"}]
