# Per-helper tick. Executed as/at the helper.

tag @s add helper.self
execute store result score @s helper_hx run data get entity @s Pos[0]
execute store result score @s helper_hy run data get entity @s Pos[1]
execute store result score @s helper_hz run data get entity @s Pos[2]
execute store result score #last_hx helper_config run data get entity @s Pos[0]
execute store result score #last_hy helper_config run data get entity @s Pos[1]
execute store result score #last_hz helper_config run data get entity @s Pos[2]
execute store result storage helper:last x int 1 run data get entity @s Pos[0]
execute store result storage helper:last z int 1 run data get entity @s Pos[2]
scoreboard players add @s helper_chunk_cd 1
execute unless score @s helper_fx = @s helper_fx run function helper:chunk/force_here
execute if score @s helper_chunk_cd matches 20.. run function helper:chunk/refresh
execute if score @s helper_chunk_cd matches 20.. run scoreboard players set @s helper_chunk_cd 0
tag @a[tag=helper.my_owner] remove helper.my_owner
execute as @a if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_owner
execute as @a[tag=helper.my_owner,limit=1] run scoreboard players operation @s helper_hx = @e[tag=helper.self,limit=1] helper_hx
execute as @a[tag=helper.my_owner,limit=1] run scoreboard players operation @s helper_hy = @e[tag=helper.self,limit=1] helper_hy
execute as @a[tag=helper.my_owner,limit=1] run scoreboard players operation @s helper_hz = @e[tag=helper.self,limit=1] helper_hz

execute unless entity @a[tag=helper.my_owner,limit=1] run tag @s remove helper.self
execute unless entity @a[tag=helper.my_owner,limit=1] run return 0

team join helper @s
team join helper @a[tag=helper.my_owner,limit=1]

execute if score @s helper_sword matches 1.. run scoreboard players remove @s helper_sword 1
execute if score @s helper_bow matches 1.. run scoreboard players remove @s helper_bow 1
execute if score @s helper_dodge matches 1.. run scoreboard players remove @s helper_dodge 1
execute if score @s helper_atk_cd matches 1.. run scoreboard players remove @s helper_atk_cd 1

scoreboard players set @s helper_on_horse 0
execute on vehicle if entity @s[tag=helper.horse] run scoreboard players set @e[tag=helper.self,limit=1] helper_on_horse 1

scoreboard players set @s helper_owner_mounted 0
execute as @a[tag=helper.my_owner,limit=1] on vehicle if entity @s[type=#helper:mounts] run scoreboard players set @e[tag=helper.self,limit=1] helper_owner_mounted 1

function helper:jobs/tick
function helper:horse/tick

execute if score @s helper_on_horse matches 0 run function helper:move/gravity

effect give @s minecraft:fire_resistance 4 0 true
data modify entity @s Fire set value 0s
data merge entity @s {PersistenceRequired:1b,NoAI:1b}

function helper:trust/detect_attack
function helper:combat/calm_golems

scoreboard players set #working helper_config 0
execute if score @s helper_job matches 5..13 run scoreboard players set #working helper_config 1

execute if score #working helper_config matches 0 if entity @a[tag=helper.my_owner,distance=..10] run function helper:combat/dodge
execute if score #working helper_config matches 1 run function helper:combat/dodge

tag @e[tag=helper.targeted] remove helper.targeted
scoreboard players set #owner_threat helper_config 0

# Priority-target warp-to-OWNER: skip during hunt (job 11) — hunt journeys to the foe instead
execute unless score @s helper_job matches 11 unless score @s helper_job matches 12 unless score @s helper_job matches 13 if entity @e[tag=helper.priority_target,limit=1] unless entity @e[tag=helper.priority_target,distance=..32,limit=1] if entity @a[tag=helper.my_owner,limit=1] run tp @s @a[tag=helper.my_owner,limit=1]
# Drop stale priority tags on dead/far attackers (not during active hunt — hunt keeps tag)
execute unless score @s helper_job matches 11 unless score @s helper_job matches 12 unless score @s helper_job matches 13 as @e[tag=helper.priority_target] unless entity @s[distance=..48] run tag @s remove helper.priority_target

execute if score @s helper_job matches 7 run function helper:jobs/raid_select
execute if score @s helper_job matches 7 if entity @e[tag=helper.targeted,limit=1] run function helper:combat/los_check
execute if score @s helper_job matches 7 if score #los helper_config matches 0 run tag @e[tag=helper.targeted] remove helper.targeted
# Hunt manages its own targeting
execute unless score @s helper_job matches 7 unless score @s helper_job matches 5 unless score @s helper_job matches 11 unless score @s helper_job matches 12 unless score @s helper_job matches 13 run function helper:combat/pick_seen
execute if score @s helper_job matches 5 unless score @s helper_gtype matches 12 run function helper:combat/pick_seen
execute if score @s helper_job matches 5 if score @s helper_gtype matches 12 if entity @e[type=#helper:hostiles,distance=..8,limit=1] run function helper:combat/pick_seen
execute if score @s helper_job matches 5 if score @s helper_gtype matches 12 unless entity @e[tag=helper.targeted,limit=1] run function helper:combat/pick_food

# Owner defense — still evaluate, but do not snap-teleport during hunt
function helper:combat/defend_owner

execute unless score @s helper_job matches 11 unless score @s helper_job matches 12 unless score @s helper_job matches 13 if score #owner_threat helper_config matches 1 unless entity @a[tag=helper.my_owner,distance=..16] if entity @a[tag=helper.my_owner,limit=1] run tp @s @a[tag=helper.my_owner,limit=1]

# Fight visible targets (hunt fight is inside hunt_player)
execute unless score @s helper_job matches 11 unless score @s helper_job matches 12 unless score @s helper_job matches 13 if entity @e[tag=helper.targeted,limit=1] if score #los helper_config matches 1 run function helper:combat/fight
execute unless score @s helper_job matches 11 unless score @s helper_job matches 12 unless score @s helper_job matches 13 if entity @e[tag=helper.targeted,limit=1] if score #los helper_config matches 0 if score #owner_threat helper_config matches 1 run function helper:combat/fight
execute unless score @s helper_job matches 11 unless score @s helper_job matches 12 unless score @s helper_job matches 13 if entity @e[tag=helper.targeted,limit=1] if score #los helper_config matches 0 if entity @e[tag=helper.priority_target,limit=1] run function helper:combat/fight

execute if score @s helper_job matches 5 unless entity @e[tag=helper.targeted,limit=1] run function helper:jobs/cut_trees
execute if score @s helper_job matches 6 unless entity @e[tag=helper.targeted,limit=1] run function helper:jobs/place_chest
execute if score @s helper_job matches 7 run function helper:jobs/raid_here
execute if score @s helper_job matches 8 run function helper:jobs/dig_straight
execute if score @s helper_job matches 9 run function helper:jobs/smelt_job
execute if score @s helper_job matches 10 run function helper:jobs/craft_job
execute if score @s helper_job matches 11 run function helper:jobs/hunt_player
execute if score @s helper_job matches 12 run function helper:jobs/lay_rails
execute if score @s helper_job matches 13 run function helper:jobs/clear_wall_torches

execute if score #working helper_config matches 1 run function helper:jobs/finish_tick
execute if score #working helper_config matches 1 run return 0

scoreboard players set #stay_with helper_config 0
execute unless score @s helper_mode matches 1..2 run scoreboard players set #stay_with helper_config 1

execute if score #stay_with helper_config matches 1 unless entity @a[tag=helper.my_owner,distance=..10] unless entity @e[tag=helper.targeted,limit=1] run function helper:follow/keep_up
execute if score #stay_with helper_config matches 1 if entity @a[tag=helper.my_owner,distance=..10] unless entity @e[tag=helper.targeted,limit=1] run function helper:follow/keep_up

execute if score #stay_with helper_config matches 0 unless entity @e[tag=helper.targeted,limit=1] run function helper:combat/idle_behavior

function helper:jobs/finish_tick
