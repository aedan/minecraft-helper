execute if score @s helper_dodge matches 1.. run return 0
scoreboard players add @s helper_strafe 1
execute if score @s helper_strafe matches 2.. run scoreboard players set @s helper_strafe 0
execute if score @s helper_strafe matches 0 at @s run function helper:move/left
execute if score @s helper_strafe matches 1 at @s run function helper:move/right
scoreboard players set @s helper_dodge 8
