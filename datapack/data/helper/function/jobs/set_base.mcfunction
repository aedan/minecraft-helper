tag @a[tag=helper.my_owner,limit=1] add helper.cmd
execute as @a[tag=helper.my_owner,limit=1] at @s run function helper:combat/place_base_marker
tag @a[tag=helper.cmd] remove helper.cmd
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Base set.","color":"green"}]
function helper:jobs/done
