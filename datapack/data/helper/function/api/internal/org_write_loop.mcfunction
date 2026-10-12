execute if score #org_i helper_config >= #org_n helper_config run return 0
execute store result storage helper:api org.cur.i int 1 run scoreboard players get #org_i helper_config
function helper:api/internal/org_write_one with storage helper:api org.cur
scoreboard players add #org_i helper_config 1
function helper:api/internal/org_write_loop
