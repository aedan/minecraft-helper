execute at @s anchored eyes positioned ^ ^ ^2 as @a[distance=..2.5,limit=1] unless entity @s[distance=..0.1] run tag @s add helper.trust_target
execute as @a[tag=helper.trust_target,limit=1] run scoreboard players set @s trust_level 1
execute as @a[tag=helper.trust_target,limit=1] run tag @s remove helper.friend
execute if entity @a[tag=helper.trust_target,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Removed trust from ","color":"yellow"},{"selector":"@a[tag=helper.trust_target,limit=1]"}]
execute unless entity @a[tag=helper.trust_target,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Look at a nearby player first.","color":"red"}]
tag @a remove helper.trust_target
