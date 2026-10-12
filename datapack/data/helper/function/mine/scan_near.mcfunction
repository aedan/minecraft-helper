# Check a 3x3x3 around the helper for diamond ore. No recursion.
execute positioned ~ ~ ~ if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~1 ~ ~ if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~-1 ~ ~ if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~ ~ ~1 if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~ ~ ~-1 if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~1 ~ ~1 if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~1 ~ ~-1 if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~-1 ~ ~1 if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~-1 ~ ~-1 if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~ ~1 ~ if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~ ~-1 ~ if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~2 ~ ~ if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~-2 ~ ~ if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~ ~ ~2 if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
execute positioned ~ ~ ~-2 if block ~ ~ ~ #helper:diamond_ores run function helper:mine/break_here
