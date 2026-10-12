# After a successful forward step: if this step was powered, reset phase; else increment.
scoreboard players set #rail_place_pow helper_config 0
execute if score @s helper_gt1 matches 1.. if score @s helper_gt2 >= @s helper_gt1 run scoreboard players set #rail_place_pow helper_config 1
execute if score #rail_place_pow helper_config matches 1 run scoreboard players set @s helper_gt2 0
execute if score #rail_place_pow helper_config matches 0 if score @s helper_gt1 matches 1.. run scoreboard players add @s helper_gt2 1
