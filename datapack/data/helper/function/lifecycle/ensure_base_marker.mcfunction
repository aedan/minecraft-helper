# As owner (helper.summoner/cmd). Recreate base marker at stored bx/by/bz if none loaded.
scoreboard players set #has_base helper_config 0
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run scoreboard players set #has_base helper_config 1
execute if score #has_base helper_config matches 1 run return 0
execute unless score @s helper_bx = @s helper_bx run return 0
execute store result storage helper:tmp x int 1 run scoreboard players get @s helper_bx
execute store result storage helper:tmp y int 1 run scoreboard players get @s helper_by
execute store result storage helper:tmp z int 1 run scoreboard players get @s helper_bz
function helper:lifecycle/place_base_at with storage helper:tmp
