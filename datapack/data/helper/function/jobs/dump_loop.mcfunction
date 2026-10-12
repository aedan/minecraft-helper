execute if score @s helper_wood matches 0 run return 0
execute if score #slot helper_config matches 27.. run return 0
execute store result storage helper:dump slot int 1 run scoreboard players get #slot helper_config
execute if score @s helper_wood matches 64.. run function helper:jobs/dump_stack with storage helper:dump
execute if score @s helper_wood matches 64.. run scoreboard players add #slot helper_config 1
execute if score @s helper_wood matches 64.. run return run function helper:jobs/dump_loop
execute if score @s helper_wood matches 1..63 run function helper:jobs/dump_partial with storage helper:dump
