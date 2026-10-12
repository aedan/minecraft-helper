# Pull nearby drops to the helper, then count and remove them.
execute if score @s helper_gtype matches 1 as @e[type=item,distance=..16] run function helper:jobs/vacuum_wood_item
execute if score @s helper_gtype matches 2 as @e[type=item,distance=..8] if items entity @s contents minecraft:coal run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 3 as @e[type=item,distance=..8] if items entity @s contents minecraft:raw_iron run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 4 as @e[type=item,distance=..8] if items entity @s contents minecraft:raw_copper run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 5 as @e[type=item,distance=..8] if items entity @s contents minecraft:raw_gold run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 6 as @e[type=item,distance=..8] if items entity @s contents minecraft:redstone run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 7 as @e[type=item,distance=..8] if items entity @s contents minecraft:lapis_lazuli run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 8 as @e[type=item,distance=..8] if items entity @s contents minecraft:diamond run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 9 as @e[type=item,distance=..8] if items entity @s contents minecraft:emerald run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 10 as @e[type=item,distance=..8] if items entity @s contents minecraft:quartz run function helper:jobs/pickup_log
execute if score @s helper_gtype matches 11 as @e[type=item,distance=..8] if items entity @s contents minecraft:ancient_debris run function helper:jobs/pickup_log
execute as @e[type=item,distance=..8] if items entity @s contents #minecraft:leaves run kill @s
