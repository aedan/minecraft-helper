# Positioned at base marker. Put ore + fuel into ~1 ~ ~ blast/furnace.
execute unless block ~1 ~ ~ minecraft:furnace unless block ~1 ~ ~ minecraft:blast_furnace unless block ~1 ~ ~ minecraft:smoker run return 0

# Fuel
item replace block ~1 ~ ~ container.1 with minecraft:coal 16

# Input by gtype (default raw iron)
data modify storage helper:smelt ore set value "minecraft:raw_iron"
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 3 run data modify storage helper:smelt ore set value "minecraft:raw_iron"
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 4 run data modify storage helper:smelt ore set value "minecraft:raw_copper"
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 5 run data modify storage helper:smelt ore set value "minecraft:raw_gold"
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 2 run data modify storage helper:smelt ore set value "minecraft:coal_ore"
execute if score @e[tag=helper.self,limit=1] helper_gtype matches 11 run data modify storage helper:smelt ore set value "minecraft:ancient_debris"
# Use count from helper_wood (gathered) or default 16
scoreboard players set #smelt_n helper_config 16
execute if score @e[tag=helper.self,limit=1] helper_wood matches 1.. run scoreboard players operation #smelt_n helper_config = @e[tag=helper.self,limit=1] helper_wood
execute if score #smelt_n helper_config matches 65.. run scoreboard players set #smelt_n helper_config 64
execute store result storage helper:smelt count int 1 run scoreboard players get #smelt_n helper_config
function helper:smelt/put_ore with storage helper:smelt
