# Ore location system: scan for ore in a 32-block radius

# Scan for each ore type (simplified: just check a few blocks)
execute store result score #iron_ore helper_config run data get block ~ ~ ~ minecraft:iron_ore
execute store result score #gold_ore helper_config run data get block ~1 ~ ~ minecraft:gold_ore
execute store result score #diamond_ore helper_config run data get block ~ ~ ~1 minecraft:diamond_ore
execute store result score #coal_ore helper_config run data get block ~-1 ~ ~ minecraft:coal_ore

# Report findings
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Ore scan complete.\n","color":"green"},{"text":"Iron: ","color":"gray"},{"selector":"@s","color":"white"}]
