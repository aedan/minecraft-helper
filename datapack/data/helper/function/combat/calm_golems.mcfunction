# Village iron golems aggro zombies. Clear anger if they are targeting this helper.
execute as @e[type=minecraft:iron_golem,distance=..24] at @s on target if entity @s[tag=helper.active] run data merge entity @e[type=minecraft:iron_golem,distance=..1,limit=1,sort=nearest] {AngerTime:0}
