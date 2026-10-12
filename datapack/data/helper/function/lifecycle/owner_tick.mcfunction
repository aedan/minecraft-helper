# Per-owner lifecycle. Executed as the owning player.
# Keeps helper findable via forceload recovery, handles recall, respawns on death.

# Unset scores do not match 0 — normalize so auto-recover can start.
execute unless score @s helper_recall matches 0.. run scoreboard players set @s helper_recall 0
execute unless score @s helper_missing matches 0.. run scoreboard players set @s helper_missing 0
execute unless score @s helper_respawn_cd matches 0.. run scoreboard players set @s helper_respawn_cd 0

# Same short memory as helper_tick (still recorded if the helper is unloaded).
execute at @s run function helper:memory/snapshot

tag @s add helper.owner_tick
scoreboard players set #found helper_config 0
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.owner_tick,limit=1] helper_id run scoreboard players set #found helper_config 1

# Helper present: clear missing, finish any pending recall by warping him in.
execute if score #found helper_config matches 1 run scoreboard players set @s helper_missing 0
execute if score #found helper_config matches 1 if score @s helper_recall matches 1.. run function helper:lifecycle/recall_success
execute if score #found helper_config matches 1 run tag @s remove helper.owner_tick
execute if score #found helper_config matches 1 run return 0

# Helper not in any loaded chunk (unloaded or dead).
scoreboard players add @s helper_missing 1

# Active recall / recover: keep trying forceload then respawn if gone.
execute if score @s helper_recall matches 1.. run function helper:lifecycle/recall_tick
execute if score @s helper_recall matches 0 if score @s helper_missing matches 40.. run function helper:lifecycle/start_recover

tag @s remove helper.owner_tick
