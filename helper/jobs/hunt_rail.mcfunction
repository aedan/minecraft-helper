# Rail transport: if rails lead toward hunt target, reuse/spawn minecart by helper_id and ride.
# No spawn loops. Steer cart along rails toward target (tp-along-rail, not TP-to-kill).

# Already riding our cart?
scoreboard players set #in_cart helper_config 0
execute on vehicle if entity @s[type=minecart] run scoreboard players set #in_cart helper_config 1

# Resolve bound cart
tag @e[type=minecart,tag=helper.my_cart] remove helper.my_cart
execute as @e[type=minecart,tag=helper.cart] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_cart

# Not in cart: only board if we are on/near rails that can progress toward target
execute if score #in_cart helper_config matches 0 at @s unless block ~ ~ ~ #minecraft:rails unless block ~ ~-1 ~ #minecraft:rails unless entity @e[type=minecart,distance=..3,limit=1] run return 0

# Prefer any nearby existing minecart on rails (board first), else our bound cart, else spawn once
execute if score #in_cart helper_config matches 0 at @s if entity @e[type=minecart,distance=..3,limit=1] run ride @s mount @e[type=minecart,distance=..3,sort=nearest,limit=1]
execute if score #in_cart helper_config matches 0 on vehicle if entity @s[type=minecart] run scoreboard players set #in_cart helper_config 1
# Tag boarded world cart as ours if unbound
execute if score #in_cart helper_config matches 1 on vehicle if entity @s[type=minecart,tag=!helper.cart] run tag @s add helper.cart
execute if score #in_cart helper_config matches 1 on vehicle if entity @s[type=minecart] run scoreboard players operation @s helper_id = @e[tag=helper.self,limit=1] helper_id

execute if score #in_cart helper_config matches 0 if entity @e[type=minecart,tag=helper.my_cart,limit=1] unless entity @e[type=minecart,tag=helper.my_cart,distance=..4,limit=1] at @s run tp @e[type=minecart,tag=helper.my_cart,limit=1] ~ ~ ~
execute if score #in_cart helper_config matches 0 if entity @e[type=minecart,tag=helper.my_cart,limit=1] run ride @s mount @e[type=minecart,tag=helper.my_cart,sort=nearest,limit=1]
execute if score #in_cart helper_config matches 0 if entity @e[type=minecart,tag=helper.my_cart,limit=1] run scoreboard players set #in_cart helper_config 1

# Spawn one cart on rail under/at feet
execute if score #in_cart helper_config matches 0 at @s if block ~ ~ ~ #minecraft:rails run summon minecraft:minecart ~ ~ ~ {Tags:["helper.cart","helper.cart_new"]}
execute if score #in_cart helper_config matches 0 at @s if block ~ ~-1 ~ #minecraft:rails unless entity @e[type=minecart,tag=helper.cart_new,limit=1] run summon minecraft:minecart ~ ~-0.1 ~ {Tags:["helper.cart","helper.cart_new"]}
execute if entity @e[type=minecart,tag=helper.cart_new,limit=1] run scoreboard players operation @e[type=minecart,tag=helper.cart_new,limit=1] helper_id = @s helper_id
execute if entity @e[type=minecart,tag=helper.cart_new,limit=1] run ride @s mount @e[type=minecart,tag=helper.cart_new,limit=1]
execute if entity @e[type=minecart,tag=helper.cart_new,limit=1] run scoreboard players set #in_cart helper_config 1
tag @e[type=minecart,tag=helper.cart_new] remove helper.cart_new
tag @e[type=minecart,tag=helper.my_cart] remove helper.my_cart

execute if score #in_cart helper_config matches 0 run return 0

# Steer: face target, nudge cart along rail in that direction (stay on rails only)
execute on vehicle at @s facing entity @a[tag=helper.hunt_target,limit=1] feet run tp @s ~ ~ ~ ~ ~
# Forward if next block is rail (at cart y or y-1)
execute on vehicle at @s if block ^ ^ ^0.7 #minecraft:rails run tp @s ^ ^ ^0.7
execute on vehicle at @s unless block ^ ^ ^0.7 #minecraft:rails if block ^ ^-1 ^0.7 #minecraft:rails run tp @s ^ ^-1 ^0.7
execute on vehicle at @s unless block ^ ^ ^0.7 #minecraft:rails unless block ^ ^-1 ^0.7 #minecraft:rails if block ^ ^1 ^0.7 #minecraft:rails run tp @s ^ ^1 ^0.7
# Try slight left/right rail forks toward target
execute on vehicle at @s unless block ^ ^ ^0.7 #minecraft:rails unless block ^ ^-1 ^0.7 #minecraft:rails if block ^0.7 ^ ^0.5 #minecraft:rails run tp @s ^0.7 ^ ^0.5
execute on vehicle at @s unless block ^ ^ ^0.7 #minecraft:rails unless block ^ ^-1 ^0.7 #minecraft:rails if block ^-0.7 ^ ^0.5 #minecraft:rails run tp @s ^-0.7 ^ ^0.5

# End of line / no rail ahead: dismount, cleanup later via stuck overland
execute on vehicle at @s unless block ~ ~ ~ #minecraft:rails unless block ~ ~-1 ~ #minecraft:rails run ride @e[tag=helper.self,limit=1] dismount
function helper:jobs/hunt_unstuck
