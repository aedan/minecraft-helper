# Scan volume around helper: remove ALL wall torches; remove outer/side floor redstone_torch; KEEP feet-center torch.
# Accumulates cleared count on helper_no_tree (reset by clear_work at job start).

# 1) Every redstone_wall_torch in a 7x5x7 box (both tunnel walls, ahead, behind, slight Y range)
execute at @s store result score #torch_n helper_config run fill ~-3 ~-1 ~-3 ~3 ~3 ~3 air replace minecraft:redstone_wall_torch
scoreboard players operation @s helper_no_tree += #torch_n helper_config

# 2) Outer/side floor redstone_torch ring (never touch ~ ~ ~ center). store success zeros on miss.
execute at @s store success score #torch_n helper_config if block ~1 ~ ~ minecraft:redstone_torch run setblock ~1 ~ ~ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~-1 ~ ~ minecraft:redstone_torch run setblock ~-1 ~ ~ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~ ~ ~1 minecraft:redstone_torch run setblock ~ ~ ~1 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~ ~ ~-1 minecraft:redstone_torch run setblock ~ ~ ~-1 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~2 ~ ~ minecraft:redstone_torch run setblock ~2 ~ ~ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~-2 ~ ~ minecraft:redstone_torch run setblock ~-2 ~ ~ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~ ~ ~2 minecraft:redstone_torch run setblock ~ ~ ~2 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~ ~ ~-2 minecraft:redstone_torch run setblock ~ ~ ~-2 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~2 ~ ~1 minecraft:redstone_torch run setblock ~2 ~ ~1 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~2 ~ ~-1 minecraft:redstone_torch run setblock ~2 ~ ~-1 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~-2 ~ ~1 minecraft:redstone_torch run setblock ~-2 ~ ~1 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~-2 ~ ~-1 minecraft:redstone_torch run setblock ~-2 ~ ~-1 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~1 ~ ~2 minecraft:redstone_torch run setblock ~1 ~ ~2 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~-1 ~ ~2 minecraft:redstone_torch run setblock ~-1 ~ ~2 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~1 ~ ~-2 minecraft:redstone_torch run setblock ~1 ~ ~-2 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ~-1 ~ ~-2 minecraft:redstone_torch run setblock ~-1 ~ ~-2 air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config

# 3) Facing-relative outer floors (pattern ^±2) + head-height side floor-type if present
execute at @s store success score #torch_n helper_config if block ^-2 ^ ^ minecraft:redstone_torch run setblock ^-2 ^ ^ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ^2 ^ ^ minecraft:redstone_torch run setblock ^2 ^ ^ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ^-1 ^1 ^ minecraft:redstone_torch run setblock ^-1 ^1 ^ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ^1 ^1 ^ minecraft:redstone_torch run setblock ^1 ^1 ^ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ^-2 ^1 ^ minecraft:redstone_torch run setblock ^-2 ^1 ^ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
execute at @s store success score #torch_n helper_config if block ^2 ^1 ^ minecraft:redstone_torch run setblock ^2 ^1 ^ air destroy
scoreboard players operation @s helper_no_tree += #torch_n helper_config
