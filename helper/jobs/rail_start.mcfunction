# As owner: face helper the same way, OBSERVE nearby rail pattern, force job 12 (lay rails).
# Length from #dig helper_config (reuse dig length score); default 512 (10000 = until end).
function helper:id/assign
tag @s add helper.cmd
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.rail_me
execute unless entity @e[tag=helper.rail_me,limit=1] as @e[tag=helper.active,sort=nearest,limit=1] run tag @s add helper.rail_me
execute unless entity @e[tag=helper.rail_me,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You do not have a helper.","color":"red"}]
execute unless entity @e[tag=helper.rail_me,limit=1] run tag @s remove helper.cmd
execute unless entity @e[tag=helper.rail_me,limit=1] run return 0

# Copy owner facing onto helper at owner position, then lock a stable cardinal tunnel axis.
execute at @s as @e[tag=helper.rail_me,limit=1] run tp @s ~ ~ ~ ~ ~
execute as @e[tag=helper.rail_me,limit=1] run function helper:jobs/rail_facing_snap

# Detect demonstrated rail type near owner (fallback when no period pattern)
scoreboard players set #rail_type helper_config 0
execute at @s if block ~ ~ ~ minecraft:powered_rail run scoreboard players set #rail_type helper_config 1
execute at @s if score #rail_type helper_config matches 0 if block ~ ~-1 ~ minecraft:powered_rail run scoreboard players set #rail_type helper_config 1
execute at @s if score #rail_type helper_config matches 0 if block ^ ^ ^1 minecraft:powered_rail run scoreboard players set #rail_type helper_config 1
execute at @s if score #rail_type helper_config matches 0 if block ^ ^ ^-1 minecraft:powered_rail run scoreboard players set #rail_type helper_config 1
execute at @s if score #rail_type helper_config matches 0 if block ~ ~ ~ minecraft:detector_rail run scoreboard players set #rail_type helper_config 2
execute at @s if score #rail_type helper_config matches 0 if block ~ ~-1 ~ minecraft:detector_rail run scoreboard players set #rail_type helper_config 2
execute at @s if score #rail_type helper_config matches 0 if block ~ ~ ~ minecraft:activator_rail run scoreboard players set #rail_type helper_config 3
execute at @s if score #rail_type helper_config matches 0 if block ~ ~-1 ~ minecraft:activator_rail run scoreboard players set #rail_type helper_config 3
execute if score #brain_rail helper_config matches 10..13 run scoreboard players operation #rail_type helper_config = #brain_rail helper_config
execute if score #brain_rail helper_config matches 10..13 run scoreboard players remove #rail_type helper_config 10

execute as @e[tag=helper.rail_me,limit=1] run function helper:jobs/clear_work
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_q1 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_q2 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_q3 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_job 12
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_gtype = #rail_type helper_config
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_dig_left = #dig helper_config
execute as @e[tag=helper.rail_me,limit=1] unless score @s helper_dig_left matches 1.. run scoreboard players set @s helper_dig_left 512
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gkind 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt1 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt2 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt3 0

# OBSERVE pattern at helper (cardinal yaw, pitch 0) — not owner pitch which skews scan
execute as @e[tag=helper.rail_me,limit=1] at @s run function helper:jobs/rail_learn

# Face unfinished tip so we continue into empty tunnel, not back into finished work
execute as @e[tag=helper.rail_me,limit=1] run function helper:jobs/rail_orient_tip

# When period pattern is active, normal segments are plain rail
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 1.. run scoreboard players set @s helper_gtype 0

# Visual inventory
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 1.. run item replace entity @s weapon.mainhand with minecraft:rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 1.. run item replace entity @s weapon.offhand with minecraft:powered_rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 0 if score @s helper_gtype matches 0 run item replace entity @s weapon.mainhand with minecraft:rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 0 if score @s helper_gtype matches 1 run item replace entity @s weapon.mainhand with minecraft:powered_rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 0 if score @s helper_gtype matches 2 run item replace entity @s weapon.mainhand with minecraft:detector_rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 0 if score @s helper_gtype matches 3 run item replace entity @s weapon.mainhand with minecraft:activator_rail 64

# Owner-only tellraw: what was OBSERVED (or restored from last observation cache)
scoreboard players set #rail_msg helper_config 0
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 1.. if score @s helper_gt3 matches 1 run scoreboard players set #rail_msg helper_config 1
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 1.. if score @s helper_gt3 matches 0 run scoreboard players set #rail_msg helper_config 2
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 1.. if score @s helper_gt3 matches 2 run scoreboard players set #rail_msg helper_config 8
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 0 run scoreboard players set #rail_msg helper_config 3
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 2 if score @s helper_gt1 matches 1.. run scoreboard players set #rail_msg helper_config 4
execute if score #rail_observed helper_config matches 1 if score #rail_msg helper_config matches 0 run scoreboard players set #rail_msg helper_config 5
execute if score #rail_observed helper_config matches 2 run scoreboard players set #rail_msg helper_config 6
execute if score #rail_observed helper_config matches 0 run scoreboard players set #rail_msg helper_config 7

execute if score #rail_msg helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: dual sides, powered every ","color":"green"},{"score":{"name":"#rail_period","objective":"helper_config"}},{"text":", torch center. Continuing.","color":"green"}]
execute if score #rail_msg helper_config matches 2 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: dual sides, powered every ","color":"green"},{"score":{"name":"#rail_period","objective":"helper_config"}},{"text":" (no torch). Continuing.","color":"green"}]
execute if score #rail_msg helper_config matches 8 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: dual sides, powered every ","color":"green"},{"score":{"name":"#rail_period","objective":"helper_config"}},{"text":", wall torches. Continuing.","color":"green"}]
execute if score #rail_msg helper_config matches 3 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: dual side tracks (no powered cycle). Continuing.","color":"green"}]
execute if score #rail_msg helper_config matches 4 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: center lane, powered every ","color":"green"},{"score":{"name":"#rail_period","objective":"helper_config"}},{"text":". Continuing.","color":"green"}]
execute if score #rail_msg helper_config matches 5 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed a rail pattern — continuing it.","color":"green"}]
execute if score #rail_msg helper_config matches 6 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Could not read a clear pattern here — using last saved observation.","color":"yellow"}]
execute if score #rail_msg helper_config matches 7 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"No rail pattern nearby — laying plain center rails. Stand on your sample and try again.","color":"yellow"}]

scoreboard players set #brain_rail helper_config 0
tag @e[tag=helper.rail_me] remove helper.rail_me
tag @s remove helper.cmd
