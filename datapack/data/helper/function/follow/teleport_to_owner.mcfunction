# Pet-style warp: land beside the owner, not inside them.
execute if score @s helper_on_horse matches 1 on vehicle at @a[tag=helper.my_owner,limit=1] run tp @s ^2.4 ^ ^-1.5
execute if score @s helper_on_horse matches 0 as @a[tag=helper.my_owner,limit=1] at @s run tp @e[tag=helper.self,limit=1] ^2.2 ^ ^-1.5
execute at @s unless block ~ ~ ~ #helper:passable at @a[tag=helper.my_owner,limit=1] run tp @s ~ ~ ~
execute at @s unless block ~ ~1 ~ #helper:passable at @a[tag=helper.my_owner,limit=1] run tp @s ~ ~ ~
particle minecraft:portal ~ ~1 ~ 0.3 0.6 0.3 0.02 12
scoreboard players set @s helper_stuck 0
