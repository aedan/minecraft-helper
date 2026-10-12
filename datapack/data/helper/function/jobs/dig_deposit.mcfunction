# As helper. Move nearby item entities into the dig chest (merge stacks, else append).
execute unless entity @e[type=marker,tag=helper.dig_chest,distance=..12,limit=1] run tag @e[type=marker,tag=helper.dig_chest] remove helper.dig_chest
execute unless entity @e[type=marker,tag=helper.dig_chest,limit=1] run function helper:jobs/dig_place_chest
execute unless entity @e[type=marker,tag=helper.dig_chest,limit=1] run return 0
scoreboard players set #slots helper_config 0
execute at @e[type=marker,tag=helper.dig_chest,limit=1] store result score #slots helper_config run data get block ~ ~ ~ Items
execute if score #slots helper_config matches 27.. run function helper:jobs/dig_chest_advance
execute if entity @e[type=marker,tag=helper.dig_chest,limit=1] as @e[type=item,distance=..8,limit=12] at @e[type=marker,tag=helper.dig_chest,limit=1] run function helper:jobs/dig_insert_item
