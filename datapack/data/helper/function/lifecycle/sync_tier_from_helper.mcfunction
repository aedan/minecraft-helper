tag @s add helper.cmd
execute as @e[tag=helper.active,tag=helper.tier1] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set @a[tag=helper.cmd,limit=1] helper_tier 1
execute as @e[tag=helper.active,tag=helper.tier2] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set @a[tag=helper.cmd,limit=1] helper_tier 2
execute as @e[tag=helper.active,tag=helper.tier3] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set @a[tag=helper.cmd,limit=1] helper_tier 3
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run scoreboard players set @a[tag=helper.cmd,limit=1] helper_want 1
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @a[tag=helper.cmd,limit=1] add helper.owner
tag @s remove helper.cmd
