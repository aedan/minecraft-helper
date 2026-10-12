scoreboard players set @s helper_moved 0
execute unless block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable if block ^ ^1 ^ #helper:passable if block ^ ^2 ^0.55 #helper:passable run tp @s ^ ^1 ^0.55
execute unless block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run scoreboard players set @s helper_moved 1
execute if score @s helper_moved matches 0 if block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run tp @s ^ ^ ^0.55
