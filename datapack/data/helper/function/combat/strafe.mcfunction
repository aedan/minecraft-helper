# Sidestep one direction so incoming attacks can miss.
scoreboard players add @s helper_strafe 1
execute if score @s helper_strafe matches 16.. run scoreboard players set @s helper_strafe 0
execute if score @s helper_strafe matches 0..7 at @s run function helper:move/left
execute if score @s helper_strafe matches 8..15 at @s run function helper:move/right
