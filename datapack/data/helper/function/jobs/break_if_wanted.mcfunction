scoreboard players set #wanted helper_config 0
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 2 if block ~ ~ ~ minecraft:coal_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 2 if block ~ ~ ~ minecraft:deepslate_coal_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 3 if block ~ ~ ~ minecraft:iron_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 3 if block ~ ~ ~ minecraft:deepslate_iron_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 4 if block ~ ~ ~ minecraft:copper_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 4 if block ~ ~ ~ minecraft:deepslate_copper_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 5 if block ~ ~ ~ minecraft:gold_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 5 if block ~ ~ ~ minecraft:deepslate_gold_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 5 if block ~ ~ ~ minecraft:nether_gold_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 6 if block ~ ~ ~ minecraft:redstone_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 6 if block ~ ~ ~ minecraft:deepslate_redstone_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 7 if block ~ ~ ~ minecraft:lapis_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 7 if block ~ ~ ~ minecraft:deepslate_lapis_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 8 if block ~ ~ ~ minecraft:diamond_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 8 if block ~ ~ ~ minecraft:deepslate_diamond_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 9 if block ~ ~ ~ minecraft:emerald_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 9 if block ~ ~ ~ minecraft:deepslate_emerald_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 10 if block ~ ~ ~ minecraft:nether_quartz_ore run scoreboard players set #wanted helper_config 1
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 11 if block ~ ~ ~ minecraft:ancient_debris run scoreboard players set #wanted helper_config 1
execute if score #wanted helper_config matches 1 run setblock ~ ~ ~ air destroy
