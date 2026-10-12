# No combat target: follow orders.
execute unless score @s helper_mode matches 1..3 run scoreboard players set @s helper_mode 3
execute if score @s helper_mode matches 1 run function helper:combat/idle_stay_home
execute if score @s helper_mode matches 2 run function helper:combat/idle_fetch
execute if score @s helper_mode matches 3 run function helper:combat/idle_watch_back
