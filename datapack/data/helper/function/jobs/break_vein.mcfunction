# Break the marked ore and a small vein around it.
function helper:jobs/break_if_wanted
execute positioned ~1 ~ ~ run function helper:jobs/break_if_wanted
execute positioned ~-1 ~ ~ run function helper:jobs/break_if_wanted
execute positioned ~ ~ ~1 run function helper:jobs/break_if_wanted
execute positioned ~ ~ ~-1 run function helper:jobs/break_if_wanted
execute positioned ~ ~1 ~ run function helper:jobs/break_if_wanted
execute positioned ~ ~-1 ~ run function helper:jobs/break_if_wanted
execute positioned ~1 ~ ~1 run function helper:jobs/break_if_wanted
execute positioned ~-1 ~ ~-1 run function helper:jobs/break_if_wanted
playsound minecraft:block.stone.break master @a[distance=..16] ~ ~ ~ 1 1
