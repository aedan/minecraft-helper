# Step forward, including 1-block step-up. Caller must already be facing the destination.
scoreboard players set @s helper_moved 0
execute unless block ^ ^ ^0.32 #helper:passable if block ^ ^1 ^0.32 #helper:passable if block ^ ^1 ^ #helper:passable if block ^ ^2 ^0.32 #helper:passable run tp @s ^ ^1 ^0.32
execute unless block ^ ^ ^0.32 #helper:passable if block ^ ^1 ^0.32 #helper:passable run scoreboard players set @s helper_moved 1
execute if score @s helper_moved matches 0 if block ^ ^ ^0.32 #helper:passable if block ^ ^1 ^0.32 #helper:passable run tp @s ^ ^ ^0.32
