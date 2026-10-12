# Build org.out[i] (the new Items list) for every container from org.plans[i].
execute if score #org_i helper_config >= #org_n helper_config run return 0
execute if score #org_bad helper_config matches 1.. run return 0
data modify storage helper:api org.out append value []
execute store result storage helper:api org.cur.i int 1 run scoreboard players get #org_i helper_config
function helper:api/internal/org_build_chest with storage helper:api org.cur
scoreboard players add #org_i helper_config 1
function helper:api/internal/org_build_loop
