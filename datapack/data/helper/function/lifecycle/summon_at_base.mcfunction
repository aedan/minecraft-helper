# Macro: summon at stored base x/y/z. Expects helper:tmp {x,y,z} OR uses scoreboard via prior store.
# Rebuild tmp from player scores for Y as well.
execute store result storage helper:tmp x int 1 run scoreboard players get @s helper_bx
execute store result storage helper:tmp y int 1 run scoreboard players get @s helper_by
execute store result storage helper:tmp z int 1 run scoreboard players get @s helper_bz
function helper:lifecycle/summon_at_coords with storage helper:tmp
