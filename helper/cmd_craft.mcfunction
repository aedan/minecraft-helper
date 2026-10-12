# /function helper:cmd_craft — expects storage helper:craft {item:"minecraft:stick",count:64}
# Called as the owner. Helper comes over and delivers crafted items.
function helper:id/assign
tag @s add helper.cmd
execute store result score #craft_n helper_config run data get storage helper:craft count
execute unless score #craft_n helper_config matches 1.. run scoreboard players set #craft_n helper_config 1
execute if score #craft_n helper_config matches 65.. run scoreboard players set #craft_n helper_config 64

scoreboard players set #job helper_config 10
scoreboard players set #gtype helper_config 0
execute as @e[tag=helper.active] run scoreboard players operation @s helper_id = @a[tag=helper.cmd,limit=1] helper_id
execute as @e[tag=helper.active] run function helper:jobs/force_on_self
execute unless entity @e[tag=helper.active,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You do not have a helper.","color":"red"}]
execute if entity @e[tag=helper.active,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Crafting and bringing it to you.","color":"green"}]
tag @s remove helper.cmd
