# As the nearby player, at the 2x2 origin. Consume only if this player has no helper.
function helper:id/assign
tag @s add helper.summoner
function helper:golem/has_helper
execute if entity @s[tag=helper.has_helper] run tag @s remove helper.summoner
execute if entity @s[tag=helper.has_helper] run tag @s remove helper.has_helper
execute if entity @s[tag=!helper.summoner] run return 0

fill ~ ~ ~ ~1 ~ ~1 minecraft:air
execute if block ~ ~1 ~ #helper:golem_heads run setblock ~ ~1 ~ minecraft:air
execute if block ~1 ~1 ~ #helper:golem_heads run setblock ~1 ~1 ~ minecraft:air
execute if block ~ ~1 ~1 #helper:golem_heads run setblock ~ ~1 ~1 minecraft:air
execute if block ~1 ~1 ~1 #helper:golem_heads run setblock ~1 ~1 ~1 minecraft:air

function helper:golem/spawn_tier1
particle minecraft:cloud ~0.5 ~1 ~0.5 0.6 0.6 0.6 0.01 20
playsound minecraft:entity.iron_golem.repair master @s ~ ~ ~ 1 1
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Stone Helper summoned. ","color":"gray","bold":true},{"text":"Follows you. Orders: /function helper:cmd_golem_help","color":"yellow"}]
tag @s remove helper.has_helper
tag @s remove helper.summoner
