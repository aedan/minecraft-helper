# Drive the horse toward the combat target.
execute on vehicle at @s facing entity @e[tag=helper.targeted,limit=1] feet run tp @s ~ ~ ~ ~ ~
execute on vehicle at @s if entity @e[tag=helper.targeted,distance=4..] if block ^ ^ ^0.5 #helper:passable run tp @s ^ ^ ^0.5
execute on vehicle at @s if entity @e[tag=helper.targeted,distance=..3] if block ^ ^ ^-0.3 #helper:passable run tp @s ^ ^ ^-0.3
execute on vehicle at @s if block ~ ~-0.2 ~ #helper:passable run tp @s ~ ~-0.25 ~
