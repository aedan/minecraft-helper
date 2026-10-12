tag @s remove helper.returning
tag @s remove helper.cut_announced
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Back at base with ","color":"green"},{"score":{"name":"@s","objective":"helper_wood"},"color":"white"},{"text":" items.","color":"green"}]
function helper:jobs/done
