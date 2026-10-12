execute store result score #n helper_config run data get entity @s Item.count
execute unless score #n helper_config matches 1.. store result score #n helper_config run data get entity @s count
execute unless score #n helper_config matches 1.. run scoreboard players set #n helper_config 1
execute as @e[tag=helper.self,limit=1] run scoreboard players operation @s helper_wood += #n helper_config
kill @s
