execute unless data storage helper:api org.work[0] run return 0
execute if score #org_bad helper_config matches 1.. run return 0
execute store result storage helper:api org.work[0].d int 1 run scoreboard players get #org_i helper_config
function helper:api/internal/org_build_entry with storage helper:api org.work[0]
data remove storage helper:api org.work[0]
function helper:api/internal/org_build_entries
