# Positioned on the chest block corner.
setblock ~ ~ ~ minecraft:chest destroy
summon marker ~0.5 ~0.5 ~0.5 {Tags:["helper.dig_chest"]}
execute unless entity @s[tag=helper.dig_chest_said] run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Chest is down for the tunnel drops.","color":"green"}]
tag @s add helper.dig_chest_said
