# Job 13: walk forward removing wall/outer redstone torches on BOTH sides; keep center floor torches.
# Each step scans a radius so off-center starts and re-runs still find leftovers (ahead + beside + behind).

execute unless score @s helper_dig_left matches 1.. run function helper:jobs/clear_wall_torches_finish
execute unless score @s helper_dig_left matches 1.. run return 0

function helper:jobs/rail_facing_restore

# --- Break wall/outer torches around helper (both sides, not only one column) ---
function helper:jobs/clear_wall_torches_scan

# --- Step forward if corridor continues; center floor torches must NOT abort the run ---
scoreboard players set #torch_step helper_config 0
# Flat ahead
execute at @s if block ^ ^ ^1 #helper:passable run scoreboard players set #torch_step helper_config 1
execute at @s if block ^ ^ ^1 #minecraft:rails run scoreboard players set #torch_step helper_config 1
execute at @s if block ^ ^ ^1 minecraft:redstone_torch run scoreboard players set #torch_step helper_config 1
execute at @s if block ^ ^ ^1 minecraft:redstone_wall_torch run scoreboard players set #torch_step helper_config 1
# Down-step
execute at @s if score #torch_step helper_config matches 0 if block ^ ^-1 ^1 #helper:passable run scoreboard players set #torch_step helper_config 2
execute at @s if score #torch_step helper_config matches 0 if block ^ ^-1 ^1 #minecraft:rails run scoreboard players set #torch_step helper_config 2
execute at @s if score #torch_step helper_config matches 0 if block ^ ^-1 ^1 minecraft:redstone_torch run scoreboard players set #torch_step helper_config 2
# Up-step
execute at @s if score #torch_step helper_config matches 0 if block ^ ^1 ^1 #helper:passable run scoreboard players set #torch_step helper_config 3
execute at @s if score #torch_step helper_config matches 0 if block ^ ^1 ^1 #minecraft:rails run scoreboard players set #torch_step helper_config 3
execute at @s if score #torch_step helper_config matches 0 if block ^ ^1 ^1 minecraft:redstone_torch run scoreboard players set #torch_step helper_config 3

execute if score #torch_step helper_config matches 1 at @s run tp @s ^ ^ ^1
execute if score #torch_step helper_config matches 2 at @s run tp @s ^ ^-1 ^1
execute if score #torch_step helper_config matches 3 at @s run tp @s ^ ^1 ^1
# Re-align to block center so left/right columns stay accurate after fractional drift
execute if score #torch_step helper_config matches 1..3 at @s align xz positioned ~0.5 ~ ~0.5 run tp @s ~ ~ ~ ~ ~

execute if score #torch_step helper_config matches 1..3 run scoreboard players remove @s helper_dig_left 1
execute if score #torch_step helper_config matches 1..3 run scoreboard players set @s helper_work_cd 0

# Path blocked: brief patience then finish (avoids aborting on one awkward block)
execute if score #torch_step helper_config matches 0 run scoreboard players add @s helper_work_cd 1
execute if score #torch_step helper_config matches 0 if score @s helper_work_cd matches 5.. run function helper:jobs/clear_wall_torches_finish
