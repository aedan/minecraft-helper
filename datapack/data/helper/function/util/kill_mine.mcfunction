# Kill the helper, horse, and base marker belonging to @s (player)
tag @s add helper.cmd
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.killme
execute as @e[type=horse,tag=helper.horse] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.killme
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.killme
execute as @e[type=marker,tag=helper.aim] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.killme
execute as @e[type=marker,tag=helper.tree] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.killme
execute as @e[type=marker,tag=helper.raid] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.killme
execute as @e[tag=helper.killme] run function helper:chunk/unforce_old
kill @e[tag=helper.killme]
tag @s remove helper.cmd
