# As player: if a base marker exists for our id, refresh stored coords + forceload.
tag @s add helper.cmd
scoreboard players set #has_base helper_config 0
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.sync_base
execute if entity @e[type=marker,tag=helper.sync_base,limit=1] run scoreboard players set #has_base helper_config 1
execute if score #has_base helper_config matches 1 store result score @s helper_bx run data get entity @e[type=marker,tag=helper.sync_base,limit=1] Pos[0]
execute if score #has_base helper_config matches 1 store result score @s helper_by run data get entity @e[type=marker,tag=helper.sync_base,limit=1] Pos[1]
execute if score #has_base helper_config matches 1 store result score @s helper_bz run data get entity @e[type=marker,tag=helper.sync_base,limit=1] Pos[2]
execute if score #has_base helper_config matches 1 store result score @s helper_bfx run data get entity @e[type=marker,tag=helper.sync_base,limit=1] Pos[0]
execute if score #has_base helper_config matches 1 store result score @s helper_bfz run data get entity @e[type=marker,tag=helper.sync_base,limit=1] Pos[2]
execute if score #has_base helper_config matches 1 at @e[type=marker,tag=helper.sync_base,limit=1] run forceload add ~ ~
tag @e[type=marker,tag=helper.sync_base] remove helper.sync_base
tag @s remove helper.cmd
