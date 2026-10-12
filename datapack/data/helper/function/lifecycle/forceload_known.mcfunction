# Forceload last known helper chunk and base chunk for @s (owner).
execute if score @s helper_hx = @s helper_hx store result storage helper:tmp x int 1 run scoreboard players get @s helper_hx
execute if score @s helper_hx = @s helper_hx store result storage helper:tmp z int 1 run scoreboard players get @s helper_hz
execute if score @s helper_hx = @s helper_hx run function helper:jobs/forceload_at with storage helper:tmp

execute if score @s helper_bx = @s helper_bx store result storage helper:tmp x int 1 run scoreboard players get @s helper_bx
execute if score @s helper_bx = @s helper_bx store result storage helper:tmp z int 1 run scoreboard players get @s helper_bz
execute if score @s helper_bx = @s helper_bx run function helper:jobs/forceload_at with storage helper:tmp

# Also force any loaded base marker for this id.
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.owner_tick,limit=1] helper_id at @s run forceload add ~ ~
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id at @s run forceload add ~ ~
