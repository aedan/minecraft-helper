scoreboard players set @s helper_mode 1
function helper:jobs/my_base
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run function helper:jobs/mark_here_as_base
tag @e[type=marker,tag=helper.my_base] remove helper.my_base
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Staying. I will not follow.","color":"yellow"}]
tellraw @a[tag=helper.cmd,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Staying. I will not follow.","color":"yellow"}]
function helper:jobs/done
