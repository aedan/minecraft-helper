scoreboard players set @a[tag=helper.summoner,limit=1] helper_tier 3
function helper:spawn/equip
# Do NOT hardcode CustomName to Helper — that stomps bound name (tom) after spawn/init.
data merge entity @s {CustomNameVisible:1b,hide_description:1b,description:{text:""}}
function helper:lifecycle/apply_bound_name
tag @s add helper.tier3
