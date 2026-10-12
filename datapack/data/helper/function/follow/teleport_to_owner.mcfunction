# Pet-style warp next to the owner (works across dimensions). Lands on the first safe
# spot from follow/safe_spot (solid floor, two passable blocks, no lava/fire/void);
# if none, lands on the owner.
scoreboard players set #tp_done helper_config 0
execute if score @s helper_on_horse matches 1 on vehicle at @a[tag=helper.my_owner,limit=1] run tp @s ^2.4 ^ ^-1.5
execute if score @s helper_on_horse matches 1 run scoreboard players set #tp_done helper_config 1
execute if score #tp_done helper_config matches 0 as @a[tag=helper.my_owner,limit=1] at @s align xyz positioned ~0.5 ~ ~0.5 run function helper:follow/safe_spot
execute if score #tp_done helper_config matches 0 run tp @s @a[tag=helper.my_owner,limit=1]
particle minecraft:portal ~ ~1 ~ 0.3 0.6 0.3 0.02 12
scoreboard players set @s helper_stuck 0
scoreboard players set @s helper_fall 0
