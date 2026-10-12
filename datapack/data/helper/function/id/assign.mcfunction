# Assign a unique helper_id to @s (player) if they do not have one
execute unless score @s helper_id matches 1.. run scoreboard players add #next_id helper_config 1
execute unless score @s helper_id matches 1.. run scoreboard players operation @s helper_id = #next_id helper_config
