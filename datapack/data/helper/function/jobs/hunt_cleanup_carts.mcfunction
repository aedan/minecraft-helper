# Remove minecarts bound to this helper_id (travel leftover).
tag @e[type=minecart,tag=helper.my_cart] remove helper.my_cart
execute as @e[type=minecart,tag=helper.cart] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_cart
execute at @s as @e[type=minecart,tag=helper.cart,distance=..8] run tag @s add helper.my_cart
kill @e[type=minecart,tag=helper.my_cart]
