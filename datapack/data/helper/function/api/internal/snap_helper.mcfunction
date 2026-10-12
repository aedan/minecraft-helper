# As the caller's helper. Fills storage helper:api status (see api/status).
data modify storage helper:api status.loaded set value 1b
execute store result storage helper:api status.helper.x int 1 run data get entity @s Pos[0]
execute store result storage helper:api status.helper.y int 1 run data get entity @s Pos[1]
execute store result storage helper:api status.helper.z int 1 run data get entity @s Pos[2]
execute store result storage helper:api status.helper.health int 1 run data get entity @s Health
execute store result storage helper:api status.job int 1 run scoreboard players get @s helper_job
execute store result storage helper:api status.queue[0] int 1 run scoreboard players get @s helper_q1
execute store result storage helper:api status.queue[1] int 1 run scoreboard players get @s helper_q2
execute store result storage helper:api status.queue[2] int 1 run scoreboard players get @s helper_q3
execute store result storage helper:api status.gtype int 1 run scoreboard players get @s helper_gtype
execute store result storage helper:api status.dig_left int 1 run scoreboard players get @s helper_dig_left
execute store result storage helper:api status.on_horse byte 1 run scoreboard players get @s helper_on_horse
execute if score @s helper_stay matches 1 run data modify storage helper:api status.stay set value 1b
execute if score @s helper_pf matches 1 run data modify storage helper:api status.protect_follow set value 1b
# Effective mode — same precedence as combat/apply_mode: stay_at_base > protect_follow > idle.
execute if score @s helper_stay matches 1 run data modify storage helper:api status.mode set value "stay_at_base"
execute unless score @s helper_stay matches 1 if score @s helper_pf matches 1 run data modify storage helper:api status.mode set value "protect_follow"
execute unless score @s helper_stay matches 1 if score @s helper_pf matches 1 run data modify storage helper:api status.protect set value 1b
execute unless score @s helper_stay matches 1 unless score @s helper_pf matches 1 run data modify storage helper:api status.mode set value "idle"
execute if entity @s[tag=helper.defending] run data modify storage helper:api status.defending set value 1b
execute if entity @s[tag=helper.preempted] run data modify storage helper:api status.job_paused set value 1b
execute if score @s helper_stay matches 0 if score @s helper_pf matches 0 if score @s helper_mode matches 2 run data modify storage helper:api status.mode set value "fetch"
