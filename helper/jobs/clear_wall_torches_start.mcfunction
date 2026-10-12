# As owner: clear wall/outer redstone torches along look direction; keep center floor torches.
# Length from #dig helper_config (default 512; brain may set 10000 for all-the-way). Owner-only status.
function helper:id/assign
tag @s add helper.cmd
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.torch_me
execute unless entity @e[tag=helper.torch_me,limit=1] as @e[tag=helper.active,sort=nearest,limit=1] run tag @s add helper.torch_me
execute unless entity @e[tag=helper.torch_me,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You do not have a helper.","color":"red"}]
execute unless entity @e[tag=helper.torch_me,limit=1] run tag @s remove helper.cmd
execute unless entity @e[tag=helper.torch_me,limit=1] run return 0

# Snap to owner look, lock cardinal, align to block center (so both walls land on ^±1 columns)
execute at @s as @e[tag=helper.torch_me,limit=1] run tp @s ~ ~ ~ ~ ~
execute as @e[tag=helper.torch_me,limit=1] run function helper:jobs/rail_facing_snap
execute as @e[tag=helper.torch_me,limit=1] at @s align xz positioned ~0.5 ~ ~0.5 run tp @s ~ ~ ~ ~ ~
execute as @e[tag=helper.torch_me,limit=1] run function helper:jobs/clear_work
execute as @e[tag=helper.torch_me,limit=1] run scoreboard players operation @s helper_dig_left = #dig helper_config
execute as @e[tag=helper.torch_me,limit=1] unless score @s helper_dig_left matches 1.. run scoreboard players set @s helper_dig_left 512
# helper_no_tree = cleared counter (clear_work zeroed it)
execute as @e[tag=helper.torch_me,limit=1] run scoreboard players set @s helper_work_cd 0
execute as @e[tag=helper.torch_me,limit=1] run scoreboard players set @s helper_job 13
# Immediate scan at start so we don't walk past torches underfoot on first tick
execute as @e[tag=helper.torch_me,limit=1] run function helper:jobs/clear_wall_torches_scan
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Clearing wall redstone torches on both sides — keeping floor/center ones.","color":"green"}]
tag @e[tag=helper.torch_me] remove helper.torch_me
tag @s remove helper.cmd
