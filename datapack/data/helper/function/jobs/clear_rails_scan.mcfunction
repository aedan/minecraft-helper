# Remove rails on left/center/right columns and center-floor redstone_torch only.
# Does NOT touch redstone_wall_torch or torches outside ^-1/~ /^1.
# Counts removals onto helper_no_tree.

scoreboard players set #rail_clr helper_config 0

# Left lane rails
execute at @s if block ^-1 ^ ^ #minecraft:rails run scoreboard players add #rail_clr helper_config 1
execute at @s if block ^-1 ^ ^ #minecraft:rails run setblock ^-1 ^ ^ air
execute at @s if block ^-1 ^-1 ^ #minecraft:rails run scoreboard players add #rail_clr helper_config 1
execute at @s if block ^-1 ^-1 ^ #minecraft:rails run setblock ^-1 ^-1 ^ air

# Center rails (if any) + center floor torch (pattern torch between dual lanes)
execute at @s if block ~ ~ ~ #minecraft:rails run scoreboard players add #rail_clr helper_config 1
execute at @s if block ~ ~ ~ #minecraft:rails run setblock ~ ~ ~ air
execute at @s if block ~ ~-1 ~ #minecraft:rails run scoreboard players add #rail_clr helper_config 1
execute at @s if block ~ ~-1 ~ #minecraft:rails run setblock ~ ~-1 ~ air
execute at @s if block ~ ~ ~ minecraft:redstone_torch run scoreboard players add #rail_clr helper_config 1
execute at @s if block ~ ~ ~ minecraft:redstone_torch run setblock ~ ~ ~ air
execute at @s if block ~ ~-1 ~ minecraft:redstone_torch run scoreboard players add #rail_clr helper_config 1
execute at @s if block ~ ~-1 ~ minecraft:redstone_torch run setblock ~ ~-1 ~ air

# Right lane rails
execute at @s if block ^1 ^ ^ #minecraft:rails run scoreboard players add #rail_clr helper_config 1
execute at @s if block ^1 ^ ^ #minecraft:rails run setblock ^1 ^ ^ air
execute at @s if block ^1 ^-1 ^ #minecraft:rails run scoreboard players add #rail_clr helper_config 1
execute at @s if block ^1 ^-1 ^ #minecraft:rails run setblock ^1 ^-1 ^ air

scoreboard players operation @s helper_no_tree += #rail_clr helper_config
