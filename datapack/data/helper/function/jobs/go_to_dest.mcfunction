# Walk/teleport toward the entity tagged helper.dest
execute unless entity @e[tag=helper.dest,limit=1] run return 0
execute unless entity @e[tag=helper.dest,distance=..12] run tp @s @e[tag=helper.dest,limit=1]
execute unless entity @e[tag=helper.dest,distance=..12] run return 0

execute store result score #oy helper_config run data get entity @e[tag=helper.dest,limit=1] Pos[1]
execute store result score #hy helper_config run data get entity @s Pos[1]
scoreboard players operation #dy helper_config = #oy helper_config
scoreboard players operation #dy helper_config -= #hy helper_config
execute if score #dy helper_config matches 4.. unless entity @e[tag=helper.dest,distance=..4] run tp @s @e[tag=helper.dest,limit=1]
execute if score #dy helper_config matches 4.. unless entity @e[tag=helper.dest,distance=..4] run return 0

execute if entity @e[tag=helper.dest,distance=6..] run scoreboard players add @s helper_stuck 1
execute if entity @e[tag=helper.dest,distance=..5] run scoreboard players set @s helper_stuck 0
execute if score @s helper_stuck matches 20.. run tp @s @e[tag=helper.dest,limit=1]
execute if score @s helper_stuck matches 20.. run scoreboard players set @s helper_stuck 0
execute if score @s helper_stuck matches 0 if entity @e[tag=helper.dest,distance=..2.4] run return 0

execute at @s facing entity @e[tag=helper.dest,limit=1] feet run tp @s ~ ~ ~ ~ ~
execute if entity @e[tag=helper.dest,distance=2.5..] at @s run function helper:move/forward_fast
