execute at @s run summon mannequin ~ ~1 ~ {Tags:["helper.active","helper.new","helper.tier2"],CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""},Silent:1b,PersistenceRequired:1b}
execute as @e[tag=helper.new,limit=1] run function helper:spawn/init
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:golem/gear_tier2
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:lifecycle/apply_bound_name
