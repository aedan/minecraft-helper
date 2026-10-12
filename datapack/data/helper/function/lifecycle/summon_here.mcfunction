# Summon a replacement helper at current execution position. Summoner tagged helper.summoner.
# Uses stored helper_tier on the summoner (default 3).
execute if score #spawned helper_config matches 1 run return 0
execute unless score @a[tag=helper.summoner,limit=1] helper_tier matches 1.. run scoreboard players set @a[tag=helper.summoner,limit=1] helper_tier 3

execute if score @a[tag=helper.summoner,limit=1] helper_tier matches 1 run summon mannequin ~ ~ ~ {Tags:["helper.active","helper.new","helper.tier1"],CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""},Silent:1b,PersistenceRequired:1b}
execute if score @a[tag=helper.summoner,limit=1] helper_tier matches 2 run summon mannequin ~ ~ ~ {Tags:["helper.active","helper.new","helper.tier2"],CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""},Silent:1b,PersistenceRequired:1b}
execute if score @a[tag=helper.summoner,limit=1] helper_tier matches 3.. run summon mannequin ~ ~ ~ {Tags:["helper.active","helper.new","helper.tier3"],CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""},Silent:1b,PersistenceRequired:1b}

execute as @e[tag=helper.new,limit=1] run function helper:spawn/init
execute if score @a[tag=helper.summoner,limit=1] helper_tier matches 1 as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:golem/gear_tier1
execute if score @a[tag=helper.summoner,limit=1] helper_tier matches 2 as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:golem/gear_tier2
execute if score @a[tag=helper.summoner,limit=1] helper_tier matches 3.. as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:golem/gear_tier3
scoreboard players set #spawned helper_config 1

# Apply bound name immediately after gear
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:lifecycle/apply_bound_name
