# Drop the previous helper forceload, but never unload the owner's base chunk.
execute unless score @s helper_fx = @s helper_fx run return 0

# If this helper's old forceload matches the owner's base forceload, keep it.
scoreboard players set #keep_base helper_config 0
execute as @a[tag=helper.my_owner,limit=1] if score @s helper_bfx = @s helper_bfx if score @s helper_bfx = @e[tag=helper.self,limit=1] helper_fx if score @s helper_bfz = @e[tag=helper.self,limit=1] helper_fz run scoreboard players set #keep_base helper_config 1
execute if score #keep_base helper_config matches 1 run return 0

execute store result storage helper:chunk x int 1 run scoreboard players get @s helper_fx
execute store result storage helper:chunk z int 1 run scoreboard players get @s helper_fz
function helper:chunk/unforce_at with storage helper:chunk
