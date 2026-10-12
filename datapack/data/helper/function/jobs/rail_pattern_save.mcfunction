# Persist learned pattern from helper.rail_me onto storage helper:rail_pattern.
execute store result storage helper:rail_pattern gkind int 1 run scoreboard players get @e[tag=helper.rail_me,limit=1] helper_gkind
execute store result storage helper:rail_pattern gt1 int 1 run scoreboard players get @e[tag=helper.rail_me,limit=1] helper_gt1
execute store result storage helper:rail_pattern gt2 int 1 run scoreboard players get @e[tag=helper.rail_me,limit=1] helper_gt2
execute store result storage helper:rail_pattern gt3 int 1 run scoreboard players get @e[tag=helper.rail_me,limit=1] helper_gt3
execute store result storage helper:rail_pattern gtype int 1 run scoreboard players get @e[tag=helper.rail_me,limit=1] helper_gtype
execute store result storage helper:rail_pattern yaw int 1 run scoreboard players get @e[tag=helper.rail_me,limit=1] helper_yaw
data modify storage helper:rail_pattern ok set value 1b
