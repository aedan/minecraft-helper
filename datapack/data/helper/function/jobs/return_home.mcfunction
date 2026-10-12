function helper:jobs/my_base
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run tag @a[tag=helper.my_owner,limit=1] add helper.cmd
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] as @a[tag=helper.my_owner,limit=1] at @s run function helper:combat/place_base_marker
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run tag @a[tag=helper.cmd] remove helper.cmd
function helper:jobs/my_base
tag @e[tag=helper.dest] remove helper.dest
tag @e[type=marker,tag=helper.my_base,limit=1] add helper.dest
execute if entity @e[tag=helper.dest,distance=..3,limit=1] run function helper:jobs/home_arrived
execute unless entity @e[tag=helper.dest,distance=..3,limit=1] run function helper:jobs/go_to_dest
tag @e[tag=helper.dest] remove helper.dest
tag @e[type=marker,tag=helper.my_base] remove helper.my_base
