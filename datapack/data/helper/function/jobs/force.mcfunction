# As owner. Interrupt and apply #job to every loaded helper, claiming them.
function helper:id/assign
tag @s add helper.cmd
execute as @e[tag=helper.active] run scoreboard players operation @s helper_id = @a[tag=helper.cmd,limit=1] helper_id
execute as @e[tag=helper.active] run function helper:jobs/force_on_self
execute unless entity @e[tag=helper.active,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You do not have a helper.","color":"red"}]
tag @s remove helper.cmd
