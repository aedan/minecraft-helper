scoreboard players set #kind helper_config 1
execute if block ~ ~ ~ #minecraft:oak_logs run scoreboard players set #kind helper_config 1
execute if block ~ ~ ~ minecraft:oak_log run scoreboard players set #kind helper_config 1
execute if block ~ ~ ~ minecraft:oak_wood run scoreboard players set #kind helper_config 1
execute if block ~ ~ ~ minecraft:stripped_oak_log run scoreboard players set #kind helper_config 1
execute if block ~ ~ ~ #minecraft:spruce_logs run scoreboard players set #kind helper_config 2
execute if block ~ ~ ~ minecraft:spruce_log run scoreboard players set #kind helper_config 2
execute if block ~ ~ ~ minecraft:spruce_wood run scoreboard players set #kind helper_config 2
execute if block ~ ~ ~ #minecraft:birch_logs run scoreboard players set #kind helper_config 3
execute if block ~ ~ ~ minecraft:birch_log run scoreboard players set #kind helper_config 3
execute if block ~ ~ ~ #minecraft:jungle_logs run scoreboard players set #kind helper_config 4
execute if block ~ ~ ~ minecraft:jungle_log run scoreboard players set #kind helper_config 4
execute if block ~ ~ ~ #minecraft:acacia_logs run scoreboard players set #kind helper_config 5
execute if block ~ ~ ~ minecraft:acacia_log run scoreboard players set #kind helper_config 5
execute if block ~ ~ ~ #minecraft:dark_oak_logs run scoreboard players set #kind helper_config 6
execute if block ~ ~ ~ minecraft:dark_oak_log run scoreboard players set #kind helper_config 6
execute if block ~ ~ ~ minecraft:cherry_log run scoreboard players set #kind helper_config 7
execute if block ~ ~ ~ minecraft:cherry_wood run scoreboard players set #kind helper_config 7
execute if block ~ ~ ~ minecraft:mangrove_log run scoreboard players set #kind helper_config 8
execute if block ~ ~ ~ minecraft:pale_oak_log run scoreboard players set #kind helper_config 9
scoreboard players operation @e[tag=helper.self,limit=1] helper_gkind = #kind helper_config
