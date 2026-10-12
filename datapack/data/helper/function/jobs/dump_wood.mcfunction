execute if score @s helper_wood matches 0 run return 0
function helper:jobs/set_dump_item
data merge block ~ ~ ~ {CustomName:'{"text":"Helper Loot"}'}
execute if score @s helper_gtype matches 1 run data merge block ~ ~ ~ {CustomName:'{"text":"Wood"}'}
execute if score @s helper_gtype matches 2 run data merge block ~ ~ ~ {CustomName:'{"text":"Coal"}'}
execute if score @s helper_gtype matches 3 run data merge block ~ ~ ~ {CustomName:'{"text":"Iron"}'}
execute if score @s helper_gtype matches 4 run data merge block ~ ~ ~ {CustomName:'{"text":"Copper"}'}
execute if score @s helper_gtype matches 5 run data merge block ~ ~ ~ {CustomName:'{"text":"Gold"}'}
execute if score @s helper_gtype matches 6 run data merge block ~ ~ ~ {CustomName:'{"text":"Redstone"}'}
execute if score @s helper_gtype matches 7 run data merge block ~ ~ ~ {CustomName:'{"text":"Lapis"}'}
execute if score @s helper_gtype matches 8 run data merge block ~ ~ ~ {CustomName:'{"text":"Diamonds"}'}
execute if score @s helper_gtype matches 9 run data merge block ~ ~ ~ {CustomName:'{"text":"Emeralds"}'}
execute if score @s helper_gtype matches 10 run data merge block ~ ~ ~ {CustomName:'{"text":"Quartz"}'}
execute if score @s helper_gtype matches 11 run data merge block ~ ~ ~ {CustomName:'{"text":"Debris"}'}
execute if score @s helper_gtype matches 12 run data merge block ~ ~ ~ {CustomName:'{"text":"Food"}'}
scoreboard players set #slot helper_config 0
function helper:jobs/dump_loop
