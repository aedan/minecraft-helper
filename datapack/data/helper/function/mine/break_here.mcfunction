# Break the ore at this position and drop vanilla loot.
setblock ~ ~ ~ air destroy
playsound minecraft:block.stone.break master @a[distance=..16] ~ ~ ~ 1 1
particle minecraft:crit ~ ~ ~ 0.2 0.2 0.2 0.01 8
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Mined diamond ore.","color":"green"}]
