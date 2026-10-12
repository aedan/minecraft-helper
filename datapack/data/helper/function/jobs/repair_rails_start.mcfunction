# As owner: OBSERVE nearby rail pattern, force job 15 (repair missing rails along the track).
# Does NOT jump to the unfinished tip — walks from the owner filling gaps.
# Length from #dig helper_config; default 512 (10000 = until end).
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

# Face unfinished tip FIRST so backward learn sees the good sample behind.
execute as @e[tag=helper.rail_me,limit=1] run function helper:jobs/rail_orient_tip
execute as @e[tag=helper.rail_me,limit=1] run function helper:jobs/rail_facing_restore

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
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_dig_left = #dig helper_config
execute as @e[tag=helper.rail_me,limit=1] unless score @s helper_dig_left matches 1.. run scoreboard players set @s helper_dig_left 512
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gkind 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt1 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt2 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt3 0
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_gtype = #rail_type helper_config

# OBSERVE pattern at helper (cardinal yaw, pitch 0) — backward sample authoritative
scoreboard players set #rail_period_mismatch helper_config 0
execute as @e[tag=helper.rail_me,limit=1] at @s run function helper:jobs/rail_learn

# Stay near owner (fill gaps mid-tunnel). Resync phase at current footing.
execute as @e[tag=helper.rail_me,limit=1] run function helper:jobs/rail_resync_phase

# When period pattern is active, normal segments are plain rail
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 1.. run scoreboard players set @s helper_gtype 0

# --- Owner-only EXACT observed numbers BEFORE any place ---
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation #rail_show_gkind helper_config = @s helper_gkind
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation #rail_show_gt1 helper_config = @s helper_gt1
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation #rail_show_gt2 helper_config = @s helper_gt2
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation #rail_show_gt3 helper_config = @s helper_gt3
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation #rail_show_yaw helper_config = @s helper_yaw
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed gkind=","color":"yellow"},{"score":{"name":"#rail_show_gkind","objective":"helper_config"},"color":"white"},{"text":" gt1=","color":"yellow"},{"score":{"name":"#rail_show_gt1","objective":"helper_config"},"color":"white"},{"text":" gt2=","color":"yellow"},{"score":{"name":"#rail_show_gt2","objective":"helper_config"},"color":"white"},{"text":" gt3=","color":"yellow"},{"score":{"name":"#rail_show_gt3","objective":"helper_config"},"color":"white"},{"text":" yaw=","color":"yellow"},{"score":{"name":"#rail_show_yaw","objective":"helper_config"},"color":"white"}]

# Abort: sample clearly period 6 (or other long gap) but learn locked wrong
execute if score #rail_period_mismatch helper_config matches 1.. run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"ABORT: sample shows powered every ","color":"red"},{"score":{"name":"#rail_period_mismatch","objective":"helper_config"},"color":"yellow"},{"text":" but learn locked gt1=","color":"red"},{"score":{"name":"#rail_show_gt1","objective":"helper_config"},"color":"yellow"},{"text":". Face down the tunnel on your good rails and try again.","color":"red"}]
execute if score #rail_period_mismatch helper_config matches 1.. as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_job 0
execute if score #rail_period_mismatch helper_config matches 1.. as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_dig_left 0
execute if score #rail_period_mismatch helper_config matches 1.. run scoreboard players set #brain_rail helper_config 0
execute if score #rail_period_mismatch helper_config matches 1.. run tag @e[tag=helper.rail_me] remove helper.rail_me
execute if score #rail_period_mismatch helper_config matches 1.. run tag @s remove helper.cmd
execute if score #rail_period_mismatch helper_config matches 1.. run return 0

# Abort: dual sides + powered in sample but no period
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 0 if score #rail_pow_back helper_config matches 1.. run tellraw @a[tag=helper.cmd,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"ABORT: dual rails with powered nearby but period learned as 0. Stand on the good sample facing the tip and try again.","color":"red"}]
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 0 if score #rail_pow_back helper_config matches 1.. run scoreboard players set @s helper_job 0
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 0 if score #rail_pow_back helper_config matches 1.. run scoreboard players set @s helper_dig_left 0
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 0 if score #rail_pow_back helper_config matches 1.. run scoreboard players set #brain_rail helper_config 0
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 0 if score #rail_pow_back helper_config matches 1.. run tag @s remove helper.rail_me
execute if entity @s[tag=helper.cmd] unless entity @e[tag=helper.rail_me,limit=1] run tag @s remove helper.cmd
execute unless entity @e[tag=helper.rail_me,limit=1] run return 0

# Human-readable summary
scoreboard players set #rail_msg helper_config 0
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 1.. if score @s helper_gt3 matches 1 run scoreboard players set #rail_msg helper_config 1
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 1.. if score @s helper_gt3 matches 0 run scoreboard players set #rail_msg helper_config 2
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 1.. if score @s helper_gt3 matches 2 run scoreboard players set #rail_msg helper_config 8
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 5 if score @s helper_gt1 matches 0 run scoreboard players set #rail_msg helper_config 3
execute if score #rail_observed helper_config matches 1 as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 2 if score @s helper_gt1 matches 1.. run scoreboard players set #rail_msg helper_config 4
execute if score #rail_observed helper_config matches 1 if score #rail_msg helper_config matches 0 run scoreboard players set #rail_msg helper_config 5
execute if score #rail_observed helper_config matches 2 run scoreboard players set #rail_msg helper_config 6
execute if score #rail_observed helper_config matches 0 run scoreboard players set #rail_msg helper_config 7

execute if score #rail_msg helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: dual sides, powered every ","color":"green"},{"score":{"name":"#rail_show_gt1","objective":"helper_config"}},{"text":", torch center. Phase ","color":"green"},{"score":{"name":"#rail_show_gt2","objective":"helper_config"}},{"text":" — repairing gaps from here.","color":"green"}]
execute if score #rail_msg helper_config matches 2 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: dual sides, powered every ","color":"green"},{"score":{"name":"#rail_show_gt1","objective":"helper_config"}},{"text":" (no torch). Repairing gaps.","color":"green"}]
execute if score #rail_msg helper_config matches 8 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: dual sides, powered every ","color":"green"},{"score":{"name":"#rail_show_gt1","objective":"helper_config"}},{"text":", wall torches. Repairing gaps.","color":"green"}]
execute if score #rail_msg helper_config matches 3 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: dual side tracks (no powered cycle). Repairing gaps.","color":"green"}]
execute if score #rail_msg helper_config matches 4 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed: center lane, powered every ","color":"green"},{"score":{"name":"#rail_show_gt1","objective":"helper_config"}},{"text":". Repairing gaps.","color":"green"}]
execute if score #rail_msg helper_config matches 5 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Observed a rail pattern — repairing missing rails.","color":"green"}]
execute if score #rail_msg helper_config matches 6 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Could not read a clear pattern here — using last saved observation to repair gaps.","color":"yellow"}]
execute if score #rail_msg helper_config matches 7 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"No rail pattern nearby — will fill plain center gaps. Stand on your sample and try again.","color":"yellow"}]

# Visual inventory
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 1.. run item replace entity @s weapon.mainhand with minecraft:rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 1.. run item replace entity @s weapon.offhand with minecraft:powered_rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 0 if score @s helper_gtype matches 0 run item replace entity @s weapon.mainhand with minecraft:rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 0 if score @s helper_gtype matches 1 run item replace entity @s weapon.mainhand with minecraft:powered_rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 0 if score @s helper_gtype matches 2 run item replace entity @s weapon.mainhand with minecraft:detector_rail 64
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gt1 matches 0 if score @s helper_gtype matches 3 run item replace entity @s weapon.mainhand with minecraft:activator_rail 64

# Start job ONLY now (after observe + abort gates)
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_job 15

scoreboard players set #brain_rail helper_config 0
tag @e[tag=helper.rail_me] remove helper.rail_me
tag @s remove helper.cmd
