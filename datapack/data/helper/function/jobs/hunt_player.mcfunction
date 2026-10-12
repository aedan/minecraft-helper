# Job 11: persistent PvP hunt — journey to DESIGNATED target only. No TP onto victim.
# Ends: owner stop, target dead, target offline past grace, despawn/cleanup.

function helper:jobs/hunt_unstuck
effect give @s minecraft:water_breathing 4 0 true
effect give @s minecraft:fire_resistance 4 0 true

# --- TARGETING LOCK: only helper.hunt_target for players; clear other player targets ---
tag @e[tag=helper.targeted] remove helper.targeted
# Strip opportunistic player foe targeting during hunt (keep mobs out of this lock)
execute as @a[tag=helper.foe,tag=!helper.hunt_target] run tag @s remove helper.priority_target
execute if entity @a[tag=helper.hunt_target,limit=1] run tag @a[tag=helper.hunt_target,limit=1] add helper.foe
execute if entity @a[tag=helper.hunt_target,limit=1] run tag @a[tag=helper.hunt_target,limit=1] add helper.priority_target

# --- Target dead → success ---
scoreboard players set #hunt_done helper_config 0
scoreboard players set #thp helper_config 20
execute as @a[tag=helper.hunt_target,limit=1] store result score #thp helper_config run data get entity @s Health 1
execute if entity @a[tag=helper.hunt_target,limit=1] if score #thp helper_config matches ..0 run scoreboard players set #hunt_done helper_config 1
execute if score #hunt_done helper_config matches 1 run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Hunt complete — target down.","color":"green"}]
execute if score #hunt_done helper_config matches 1 run function helper:jobs/hunt_cleanup
execute if score #hunt_done helper_config matches 1 run function helper:jobs/clear_work
execute if score #hunt_done helper_config matches 1 run function helper:jobs/done
execute if score #hunt_done helper_config matches 1 run return 0

# --- Target missing: grace via last-known ---
execute unless entity @a[tag=helper.hunt_target,limit=1] run scoreboard players add @s helper_hunt_miss 1
execute if entity @a[tag=helper.hunt_target,limit=1] run scoreboard players set @s helper_hunt_miss 0
execute unless entity @a[tag=helper.hunt_target,limit=1] if score @s helper_hunt_miss matches 1 run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Target lost — searching last known area…","color":"gray"}]
execute unless entity @a[tag=helper.hunt_target,limit=1] if score @s helper_hunt_miss matches 1..200 if score @s helper_tx = @s helper_tx run function helper:jobs/hunt_goto_last_from_scores
execute unless entity @a[tag=helper.hunt_target,limit=1] if score @s helper_hunt_miss matches 1..200 run return 0
scoreboard players set #hunt_gone helper_config 0
execute unless entity @a[tag=helper.hunt_target,limit=1] run scoreboard players set #hunt_gone helper_config 1
execute if score #hunt_gone helper_config matches 1 run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Hunt over — target gone.","color":"gray"}]
execute if score #hunt_gone helper_config matches 1 run function helper:jobs/hunt_cleanup
execute if score #hunt_gone helper_config matches 1 run function helper:jobs/clear_work
execute if score #hunt_gone helper_config matches 1 run function helper:jobs/done
execute if score #hunt_gone helper_config matches 1 run return 0

# Remember last known pos
execute as @a[tag=helper.hunt_target,limit=1] store result score @e[tag=helper.self,limit=1] helper_tx run data get entity @s Pos[0]
execute as @a[tag=helper.hunt_target,limit=1] store result score @e[tag=helper.self,limit=1] helper_ty run data get entity @s Pos[1]
execute as @a[tag=helper.hunt_target,limit=1] store result score @e[tag=helper.self,limit=1] helper_tz run data get entity @s Pos[2]

team leave @a[tag=helper.hunt_target,limit=1]

execute at @s run forceload add ~ ~
scoreboard players add @s helper_hunt_cd 1
execute if score @s helper_hunt_cd matches 40.. at @a[tag=helper.hunt_target,limit=1] run forceload add ~ ~
execute if score @s helper_hunt_cd matches 40.. run scoreboard players set @s helper_hunt_cd 0

# --- In combat range (≤24): drop mounts, compound entry / fight designated only ---
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] if score @s helper_on_horse matches 1 run function helper:horse/despawn_horse
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run function helper:jobs/hunt_cleanup_boats
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run function helper:jobs/hunt_cleanup_carts
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run function helper:jobs/hunt_unstuck
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run tag @a[tag=helper.hunt_target,limit=1] add helper.targeted
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run function helper:combat/los_check
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] if score #los helper_config matches 1 run function helper:combat/fight
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] if score #los helper_config matches 1 run return 0
# No LOS: compound entry (doors/buttons/over wall) then dig-down/overland — never blind tunnel
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run function helper:jobs/hunt_compound_entry
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run function helper:jobs/hunt_overland
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run function helper:jobs/hunt_unstuck
execute if entity @a[tag=helper.hunt_target,distance=..24,limit=1] run return 0

# --- Beyond 24: multi-modal journey ---
function helper:jobs/hunt_navigate
function helper:jobs/hunt_unstuck
