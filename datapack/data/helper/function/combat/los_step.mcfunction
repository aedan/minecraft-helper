# One sample along the current facing. Block test is FIRST so a foe behind a wall
# cannot set #los (the old distance=..2.5 test reached through solid stone).
# Hit uses a small box on the target hitbox, not distance-to-feet.
scoreboard players add #los_step helper_config 1
execute if score #los_step helper_config matches 72.. run return 0
execute unless block ~ ~ ~ #helper:passable run return 0
execute positioned ~-0.35 ~-0.35 ~-0.35 if entity @e[tag=helper.targeted,dx=0.7,dy=0.7,dz=0.7,limit=1] run scoreboard players set #los helper_config 1
execute if score #los helper_config matches 1 run return 0
execute positioned ^ ^ ^0.35 run function helper:combat/los_step
