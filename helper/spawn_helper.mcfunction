# Admin/command spawn of a netherite helper for @s
function helper:id/assign
function helper:util/kill_mine
tag @s add helper.summoner
execute at @s run summon mannequin ^ ^ ^1 {Tags:["helper.active","helper.new","helper.tier3"],CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""},Silent:1b,PersistenceRequired:1b}
execute as @e[tag=helper.new,limit=1] run function helper:spawn/init
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:golem/gear_tier3
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:lifecycle/apply_bound_name
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Netherite Protector deployed. ","color":"gold"},{"text":"Follows you and fights on your orders.","color":"green"}]
playsound minecraft:entity.wither.spawn master @s ~ ~ ~ 0.5 1.5
title @s title [{"text":"HELPER DEPLOYED","color":"gold","bold":true}]
title @s subtitle [{"text":"Watch Back mode — /function helper:cmd_golem_help","color":"gray"}]
tag @s remove helper.summoner
