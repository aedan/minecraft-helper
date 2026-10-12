# Steer the helper's horse toward the owner. Warp if you pull away.
execute unless entity @a[tag=helper.my_owner,distance=..12] on vehicle at @a[tag=helper.my_owner,limit=1] run tp @s ^1.4 ^ ^-0.8
execute unless entity @a[tag=helper.my_owner,distance=..12] run return 0
execute on vehicle at @s facing entity @a[tag=helper.my_owner,limit=1] feet run tp @s ~ ~ ~ ~ ~
execute on vehicle at @s if entity @a[tag=helper.my_owner,distance=4..] if block ^ ^ ^0.55 #helper:passable run tp @s ^ ^ ^0.55
execute on vehicle at @s if entity @a[tag=helper.my_owner,distance=4..] unless block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run tp @s ^ ^1 ^0.55
execute on vehicle at @s if block ~ ~-0.2 ~ #helper:passable run tp @s ~ ~-0.25 ~
