# Restore storage helper:rail_pattern onto helper.rail_me when present.
execute unless data storage helper:rail_pattern ok run return 0
execute store result score @e[tag=helper.rail_me,limit=1] helper_gkind run data get storage helper:rail_pattern gkind
execute store result score @e[tag=helper.rail_me,limit=1] helper_gt1 run data get storage helper:rail_pattern gt1
execute store result score @e[tag=helper.rail_me,limit=1] helper_gt2 run data get storage helper:rail_pattern gt2
execute store result score @e[tag=helper.rail_me,limit=1] helper_gt3 run data get storage helper:rail_pattern gt3
execute store result score @e[tag=helper.rail_me,limit=1] helper_gtype run data get storage helper:rail_pattern gtype
execute store result score @e[tag=helper.rail_me,limit=1] helper_yaw run data get storage helper:rail_pattern yaw
