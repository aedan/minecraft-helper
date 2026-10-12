scoreboard players set @a[tag=helper.summoner,limit=1] helper_tier 3
function helper:spawn/equip
data merge entity @s {CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""}}
tag @s add helper.tier3
function helper:lifecycle/apply_bound_name
