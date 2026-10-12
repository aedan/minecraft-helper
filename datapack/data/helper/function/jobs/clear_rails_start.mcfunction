# Owner-controlled: strip bad rail work along look direction without eating a good sample.
# Seeks forward over continuous dual-side rails (no clear), then clears rails+center floor
# redstone_torch through the messed segment. Stops if 12 continuous dual-side rails resume
# ahead, or length exhausted, or corridor empty. Length from #dig (default 256).
# Job 14. Does NOT touch wall torches or floor outside lane/center columns.

function helper:id/assign
tag @s add helper.cmd
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.rail_me
execute unless entity @e[tag=helper.rail_me,limit=1] as @e[tag=helper.active,sort=nearest,limit=1] run tag @s add helper.rail_me
execute unless entity @e[tag=helper.rail_me,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You do not have a helper.","color":"red"}]
execute unless entity @e[tag=helper.rail_me,limit=1] run tag @s remove helper.cmd
execute unless entity @e[tag=helper.rail_me,limit=1] run return 0

execute at @s as @e[tag=helper.rail_me,limit=1] run tp @s ~ ~ ~ ~ ~
execute as @e[tag=helper.rail_me,limit=1] run function helper:jobs/rail_facing_snap
execute as @e[tag=helper.rail_me,limit=1] at @s align xz positioned ~0.5 ~ ~0.5 run tp @s ~ ~ ~ ~ ~
execute as @e[tag=helper.rail_me,limit=1] run function helper:jobs/clear_work
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_dig_left = #dig helper_config
execute as @e[tag=helper.rail_me,limit=1] unless score @s helper_dig_left matches 1.. run scoreboard players set @s helper_dig_left 256
# helper_gtype: 0=seeking (skip good), 1=clearing mess
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gtype 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt2 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_work_cd 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_job 14

tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Cleaning messed rails along your look — skipping good continuous sample, stripping gaps/bad stretch ahead. Say stop to cancel.","color":"green"}]

tag @e[tag=helper.rail_me] remove helper.rail_me
tag @s remove helper.cmd
