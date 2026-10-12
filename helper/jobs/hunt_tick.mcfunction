function helper:spawn/hold_melee
execute unless entity @s[tag=helper.cut_announced] run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Hunting animals for food.","color":"green"}]
tag @s add helper.cut_announced
function helper:jobs/vacuum_meat

execute if score @s helper_wood matches 256.. run tag @s add helper.returning
execute if entity @s[tag=helper.returning] run function helper:jobs/return_home
execute if entity @s[tag=helper.returning] run return 0

tag @e[tag=helper.dest] remove helper.dest
tag @e[type=#helper:food_animals,distance=2.5..48,sort=nearest,limit=1] add helper.dest
execute if entity @e[tag=helper.dest,limit=1] run scoreboard players set @s helper_no_tree 0
execute unless entity @e[tag=helper.dest,limit=1] run scoreboard players add @s helper_no_tree 1
execute unless entity @e[tag=helper.dest,limit=1] run function helper:jobs/wander_search
execute if entity @e[tag=helper.dest,distance=2.5..,limit=1] run function helper:jobs/go_to_dest
tag @e[tag=helper.dest] remove helper.dest

execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 1.. run tag @s add helper.returning
execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 1.. run function helper:jobs/return_home
execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 0 run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"No animals nearby.","color":"gray"}]
execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 0 run function helper:jobs/clear_work
execute if score @s helper_no_tree matches 600.. if score @s helper_wood matches 0 run function helper:jobs/done
