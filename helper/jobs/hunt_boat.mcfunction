# Water transport toward hunt target. Reuse helper_id boat; prefer nearby existing boat; spawn once.

tag @e[type=oak_boat,tag=helper.my_boat] remove helper.my_boat
execute as @e[type=oak_boat,tag=helper.boat] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_boat

# Prefer any nearby boat in water (board first — faster than spawn)
execute at @s if entity @e[type=oak_boat,distance=..4,limit=1] run ride @s mount @e[type=oak_boat,distance=..4,sort=nearest,limit=1]
execute on vehicle if entity @s[type=oak_boat] run scoreboard players set #in_boat helper_config 1
execute if score #in_boat helper_config matches 1 on vehicle if entity @s[type=oak_boat,tag=!helper.boat] run tag @s add helper.boat
execute if score #in_boat helper_config matches 1 on vehicle if entity @s[type=oak_boat] run scoreboard players operation @s helper_id = @e[tag=helper.self,limit=1] helper_id
execute if score #in_boat helper_config matches 1 run return 0

# Reuse bound boat
execute if entity @e[type=oak_boat,tag=helper.my_boat,limit=1] unless entity @e[type=oak_boat,tag=helper.my_boat,distance=..4,limit=1] at @s run tp @e[type=oak_boat,tag=helper.my_boat,limit=1] ~ ~ ~
execute if entity @e[type=oak_boat,tag=helper.my_boat,limit=1] run ride @s mount @e[type=oak_boat,tag=helper.my_boat,sort=nearest,limit=1]
execute if entity @e[type=oak_boat,tag=helper.my_boat,limit=1] run scoreboard players set #in_boat helper_config 1
tag @e[type=oak_boat,tag=helper.my_boat] remove helper.my_boat
execute if score #in_boat helper_config matches 1 run return 0

# Spawn once, bind helper_id, mount
execute at @s run summon minecraft:oak_boat ~ ~ ~ {Tags:["helper.boat","helper.boat_new"]}
scoreboard players operation @e[type=oak_boat,tag=helper.boat_new,limit=1] helper_id = @s helper_id
ride @s mount @e[type=oak_boat,tag=helper.boat_new,limit=1]
tag @e[type=oak_boat,tag=helper.boat_new] remove helper.boat_new
scoreboard players set #in_boat helper_config 1
