# As helper, at helper. Feet-level chest a player can open.
# Never ^ ^1 ^ (ceiling of a 2-tall tunnel) and never the forward dig cell if a side exists.
# Sides, then one back, then two back, then back-side. If nothing works, say so once.
execute at @s positioned ^1 ^ ^ align xyz run function helper:jobs/dig_chest_try
execute if entity @e[type=marker,tag=helper.dig_chest,distance=..6,limit=1] run return 0
execute at @s positioned ^-1 ^ ^ align xyz run function helper:jobs/dig_chest_try
execute if entity @e[type=marker,tag=helper.dig_chest,distance=..6,limit=1] run return 0
execute at @s positioned ^ ^ ^-1 align xyz run function helper:jobs/dig_chest_try
execute if entity @e[type=marker,tag=helper.dig_chest,distance=..6,limit=1] run return 0
execute at @s positioned ^1 ^ ^-1 align xyz run function helper:jobs/dig_chest_try
execute if entity @e[type=marker,tag=helper.dig_chest,distance=..6,limit=1] run return 0
execute at @s positioned ^-1 ^ ^-1 align xyz run function helper:jobs/dig_chest_try
execute if entity @e[type=marker,tag=helper.dig_chest,distance=..6,limit=1] run return 0
execute at @s positioned ^ ^ ^-2 align xyz run function helper:jobs/dig_chest_try
execute if entity @e[type=marker,tag=helper.dig_chest,distance=..6,limit=1] run return 0
execute unless entity @s[tag=helper.dig_chest_said] run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"No open spot for a chest here — skipping it.","color":"yellow"}]
execute unless entity @s[tag=helper.dig_chest_said] if entity @a[tag=helper.cmd,limit=1] run tellraw @a[tag=helper.cmd,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"No open spot for a chest here — skipping it.","color":"yellow"}]
tag @s add helper.dig_chest_said
