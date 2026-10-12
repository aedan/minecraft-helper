# Advance recall state. Chunks need a few ticks after forceload before entities appear.
scoreboard players add @s helper_recall 1

# Re-assert forceload every 10 ticks.
execute if score @s helper_recall matches 10 run function helper:lifecycle/forceload_known
execute if score @s helper_recall matches 20 run function helper:lifecycle/forceload_known
execute if score @s helper_recall matches 40 run function helper:lifecycle/forceload_known

# Try to claim any mannequin that appeared in newly loaded chunks with our id, or rebind nearest.
execute as @e[type=minecraft:mannequin] run tag @s add helper.active
scoreboard players set #found helper_config 0
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.owner_tick,limit=1] helper_id run scoreboard players set #found helper_config 1
execute if score #found helper_config matches 0 as @e[tag=helper.active,sort=nearest,limit=1] unless score @s helper_id matches 1.. run scoreboard players operation @s helper_id = @a[tag=helper.owner_tick,limit=1] helper_id
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.owner_tick,limit=1] helper_id run scoreboard players set #found helper_config 1

execute if score #found helper_config matches 1 run function helper:lifecycle/recall_success
execute if score #found helper_config matches 1 run return 0

# After ~3s still missing → treat as dead and respawn.
execute if score @s helper_recall matches 60.. run function helper:lifecycle/respawn
