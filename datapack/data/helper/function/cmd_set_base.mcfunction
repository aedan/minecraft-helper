function helper:id/assign
tag @s add helper.cmd
execute at @s run function helper:combat/place_base_marker
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Base set. ","color":"green"},{"text":"Use Stay Home to patrol here.","color":"gray"}]
tag @s remove helper.cmd
playsound minecraft:block.beacon.activate master @s ~ ~ ~ 1 1
