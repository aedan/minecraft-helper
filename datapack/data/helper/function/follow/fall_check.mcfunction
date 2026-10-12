# As/at a protect-and-follow helper. Fall recovery: if the helper is 3+ blocks below the
# owner for 40 ticks in a row (2 s) it is stuck in a hole/ravine; 12+ below triggers at once.
# Climbing back to within 2 blocks resets the counter. Disabled at base (apply_mode).
execute store result score #oy helper_config run data get entity @a[tag=helper.my_owner,limit=1] Pos[1]
execute store result score #hy helper_config run data get entity @s Pos[1]
scoreboard players operation #dy helper_config = #oy helper_config
scoreboard players operation #dy helper_config -= #hy helper_config
execute if score #dy helper_config matches ..2 run scoreboard players set @s helper_fall 0
execute if score #dy helper_config matches 3.. run scoreboard players add @s helper_fall 1
execute if score #dy helper_config matches 12.. run scoreboard players set @s helper_fall 40
execute if score @s helper_fall matches 40.. run function helper:follow/teleport_to_owner
