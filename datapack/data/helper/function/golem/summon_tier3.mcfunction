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
execute if block ~ ~2 ~ minecraft:diamond_block run setblock ~ ~2 ~ minecraft:air
execute if block ~1 ~2 ~ minecraft:diamond_block run setblock ~1 ~2 ~ minecraft:air
execute if block ~ ~2 ~1 minecraft:diamond_block run setblock ~ ~2 ~1 minecraft:air
execute if block ~1 ~2 ~1 minecraft:diamond_block run setblock ~1 ~2 ~1 minecraft:air

execute at @s run summon mannequin ~ ~1 ~ {Tags:["helper.active","helper.new","helper.tier3"],CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""},Silent:1b,PersistenceRequired:1b}
execute as @e[tag=helper.new,limit=1] run function helper:spawn/init
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:golem/gear_tier3
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:lifecycle/apply_bound_name

particle minecraft:cloud ~0.5 ~1 ~0.5 0.6 0.6 0.6 0.01 30
playsound minecraft:entity.wither.spawn master @s ~ ~ ~ 0.6 1.4
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Netherite Helper summoned. ","color":"dark_purple","bold":true},{"text":"Full gear, bow, sword, shield.","color":"gold"}]
tag @s remove helper.has_helper
tag @s remove helper.summoner
