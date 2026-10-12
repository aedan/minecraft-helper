scoreboard players set @s helper_mode 3
tp @s @a[tag=helper.my_owner,limit=1]
execute unless entity @a[tag=helper.my_owner,limit=1] run tp @s @a[tag=helper.cmd,limit=1]
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Coming to you.","color":"green"}]
function helper:jobs/done
