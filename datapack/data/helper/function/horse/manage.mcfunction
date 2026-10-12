# Legacy entry; horse logic now runs from helper_tick.
execute as @e[tag=helper.active] at @s run function helper:horse/tick
