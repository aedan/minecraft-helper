# No combat target: follow orders. Mode comes from combat/apply_mode.
# 1 stay at base, 2 fetch (legacy), 3 protect-and-follow (handled in helper_tick), 4 idle.
execute unless score @s helper_mode matches 1..4 run scoreboard players set @s helper_mode 3
execute if score @s helper_mode matches 1 run function helper:combat/idle_stay_home
execute if score @s helper_mode matches 2 run function helper:combat/idle_fetch
execute if score @s helper_mode matches 3 run function helper:combat/idle_watch_back
# 4: stand still.
