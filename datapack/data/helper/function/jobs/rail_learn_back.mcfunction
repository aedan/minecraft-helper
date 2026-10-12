# Recursive backward scan along look direction (max 24).
scoreboard players add #rail_scan helper_config 1
scoreboard players set #rail_any helper_config 0
execute if block ^-1 ^ ^ #minecraft:rails run scoreboard players set #rail_any helper_config 1
execute if block ^-1 ^-1 ^ #minecraft:rails run scoreboard players set #rail_any helper_config 1
execute if block ^1 ^ ^ #minecraft:rails run scoreboard players set #rail_any helper_config 1
execute if block ^1 ^-1 ^ #minecraft:rails run scoreboard players set #rail_any helper_config 1
execute if block ~ ~ ~ #minecraft:rails run scoreboard players set #rail_any helper_config 1
execute if block ~ ~-1 ~ #minecraft:rails run scoreboard players set #rail_any helper_config 1
execute if score #rail_any helper_config matches 0 run scoreboard players set #rail_gap helper_config 0
function helper:jobs/rail_learn_sample
execute if score #rail_scan helper_config matches ..24 positioned ^ ^ ^-1 run function helper:jobs/rail_learn_back
