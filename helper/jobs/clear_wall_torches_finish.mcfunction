# Owner-only completion ack with cleared count; idle Tom.
execute if score @s helper_no_tree matches 1.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Cleared ","color":"green"},{"score":{"name":"@s","objective":"helper_no_tree"},"color":"yellow"},{"text":" wall/outer redstone torches.","color":"green"}]
execute unless score @s helper_no_tree matches 1.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"No wall torches left.","color":"green"}]
function helper:jobs/clear_work
function helper:jobs/done
