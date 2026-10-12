# Helper truly gone. Respawn at base if known, else beside owner. Cooldown prevents loops.
execute if score @s helper_respawn_cd matches 1.. run scoreboard players set @s helper_recall 0
execute if score @s helper_respawn_cd matches 1.. run return 0

scoreboard players set @s helper_respawn_cd 100
scoreboard players set @s helper_recall 0
scoreboard players set @s helper_missing 0

function helper:id/assign
tag @s add helper.summoner
tag @s add helper.cmd
function helper:lifecycle/ensure_base_marker

# Prefer loaded base marker.
scoreboard players set #spawned helper_config 0
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id at @s run function helper:lifecycle/summon_here
execute if score #spawned helper_config matches 1 run function helper:lifecycle/after_respawn
execute if score #spawned helper_config matches 1 run return 0

# Try stored base coords (forceload first).
execute if score @s helper_bx = @s helper_bx run function helper:lifecycle/forceload_known
execute if score @s helper_bx = @s helper_bx run function helper:lifecycle/summon_at_base with storage helper:tmp
execute if score #spawned helper_config matches 1 run function helper:lifecycle/after_respawn
execute if score #spawned helper_config matches 1 run return 0

# Fallback: beside owner.
execute at @s positioned ^1.2 ^ ^-0.8 run function helper:lifecycle/summon_here
function helper:lifecycle/after_respawn
