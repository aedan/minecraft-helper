# Prefer existing doors/gates over digging. Open wooden doors/gates; clear doorway 1x2.
# Iron doors left to hunt_compound_entry (buttons/levers) unless already open/passable.

# Wooden / non-iron doors: clear both halves to pass
execute at @s if block ^ ^ ^1 #minecraft:wooden_doors unless block ^ ^ ^1 #helper:passable run setblock ^ ^ ^1 air destroy
execute at @s if block ^ ^1 ^1 #minecraft:wooden_doors unless block ^ ^1 ^1 #helper:passable run setblock ^ ^1 ^1 air destroy
# Fallback if wooden_doors tag missing on this version — any door that isn't iron
execute at @s if block ^ ^ ^1 #minecraft:doors unless block ^ ^ ^1 minecraft:iron_door unless block ^ ^ ^1 #helper:passable run setblock ^ ^ ^1 air destroy
execute at @s if block ^ ^1 ^1 #minecraft:doors unless block ^ ^1 ^1 minecraft:iron_door unless block ^ ^1 ^1 #helper:passable run setblock ^ ^1 ^1 air destroy
execute at @s if block ^ ^ ^1 #minecraft:fence_gates unless block ^ ^ ^1 #helper:passable run setblock ^ ^ ^1 air destroy
execute at @s if block ^ ^ ^1 #minecraft:trapdoors unless block ^ ^ ^1 #helper:passable run setblock ^ ^ ^1 air destroy
execute at @s if block ^ ^1 ^1 #minecraft:trapdoors unless block ^ ^1 ^1 #helper:passable run setblock ^ ^1 ^1 air destroy
