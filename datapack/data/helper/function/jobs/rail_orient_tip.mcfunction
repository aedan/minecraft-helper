# As helper with locked helper_yaw: face the unfinished tip (direction with fewer rails ahead).
scoreboard players set #rail_fwd helper_config 0
scoreboard players set #rail_back helper_config 0
execute at @s if block ^-1 ^ ^1 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^1 ^ ^1 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^-1 ^ ^2 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^1 ^ ^2 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^-1 ^ ^3 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^1 ^ ^3 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^-1 ^ ^4 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^1 ^ ^4 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^-1 ^ ^6 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^1 ^ ^6 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^-1 ^ ^8 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^1 ^ ^8 #minecraft:rails run scoreboard players add #rail_fwd helper_config 1
execute at @s if block ^-1 ^ ^-1 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^1 ^ ^-1 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^-1 ^ ^-2 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^1 ^ ^-2 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^-1 ^ ^-3 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^1 ^ ^-3 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^-1 ^ ^-4 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^1 ^ ^-4 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^-1 ^ ^-6 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^1 ^ ^-6 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^-1 ^ ^-8 #minecraft:rails run scoreboard players add #rail_back helper_config 1
execute at @s if block ^1 ^ ^-8 #minecraft:rails run scoreboard players add #rail_back helper_config 1
# Facing into dense finished work (fwd >> back) → flip toward sparse tip
scoreboard players set #rail_flip helper_config 0
execute if score #rail_back helper_config < #rail_fwd helper_config run scoreboard players set #rail_flip helper_config 1
execute if score #rail_fwd helper_config matches 6.. if score #rail_back helper_config matches ..2 run scoreboard players set #rail_flip helper_config 1
execute if score #rail_flip helper_config matches 0 run return 0
# Compute opposite yaw into #rail_new then apply once
scoreboard players operation #rail_new helper_config = @s helper_yaw
execute if score @s helper_yaw matches 0 run scoreboard players set #rail_new helper_config 180
execute if score @s helper_yaw matches 90 run scoreboard players set #rail_new helper_config -90
execute if score @s helper_yaw matches 180 run scoreboard players set #rail_new helper_config 0
execute if score @s helper_yaw matches -180 run scoreboard players set #rail_new helper_config 0
execute if score @s helper_yaw matches -90 run scoreboard players set #rail_new helper_config 90
scoreboard players operation @s helper_yaw = #rail_new helper_config
function helper:jobs/rail_facing_restore
