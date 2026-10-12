# Job 9: navigate to base marker, ensure furnace, load ore+fuel, finish.

function helper:jobs/my_base
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"No base set — set base first.","color":"yellow"}]
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run function helper:jobs/clear_work
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run function helper:jobs/done
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run return 0

tag @e[tag=helper.dest] remove helper.dest
tag @e[type=marker,tag=helper.my_base,limit=1] add helper.dest

execute unless entity @e[tag=helper.dest,distance=..3,limit=1] run function helper:jobs/go_to_dest
execute unless entity @e[tag=helper.dest,distance=..3,limit=1] run tag @e[tag=helper.dest] remove helper.dest
execute unless entity @e[type=marker,tag=helper.my_base,distance=..3,limit=1] run tag @e[type=marker,tag=helper.my_base] remove helper.my_base
execute unless entity @e[type=marker,tag=helper.base,distance=..3,limit=1] run return 0

# Arrived at base
tag @e[tag=helper.dest] remove helper.dest
function helper:jobs/my_base
execute at @e[type=marker,tag=helper.my_base,limit=1] unless block ~1 ~ ~ minecraft:furnace unless block ~1 ~ ~ minecraft:blast_furnace unless block ~1 ~ ~ minecraft:smoker run function helper:smelt/build_furnace_once
execute at @e[type=marker,tag=helper.my_base,limit=1] run function helper:smelt/load_for_job
tag @e[type=marker,tag=helper.my_base] remove helper.my_base
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Furnace loaded at base. Smelting.","color":"green"}]
function helper:jobs/clear_work
function helper:jobs/done
