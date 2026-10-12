# Defend owner at all costs. Player targeting: designated hunt_target or priority_target only.
# During job 11: never retarget to a different player than helper.hunt_target.
# Owner-defense against mobs always allowed.

scoreboard players set #owner_threat helper_config 0
scoreboard players set #found_owner_threat helper_config 0

execute if entity @e[tag=helper.priority_target,distance=..48,limit=1] run scoreboard players set #found_owner_threat helper_config 1
execute if score #found_owner_threat helper_config matches 0 if entity @a[tag=helper.hunt_target,distance=..48,limit=1] run scoreboard players set #found_owner_threat helper_config 1
execute if score #found_owner_threat helper_config matches 0 as @a[tag=helper.my_owner,limit=1] at @s if entity @e[type=#helper:hostiles,tag=!helper.active,tag=!helper.horse,distance=..16,limit=1] run scoreboard players set #found_owner_threat helper_config 1

execute if score #found_owner_threat helper_config matches 0 run return 0

tag @e[tag=helper.targeted] remove helper.targeted

# Hunt job: lock players to hunt_target only
execute if score @s helper_job matches 11 if entity @a[tag=helper.hunt_target,distance=..48,limit=1] run tag @a[tag=helper.hunt_target,limit=1] add helper.targeted
execute if score @s helper_job matches 11 unless entity @e[tag=helper.targeted,limit=1] as @a[tag=helper.my_owner,limit=1] at @s if entity @e[type=#helper:hostiles,tag=!helper.active,tag=!helper.horse,distance=..16,limit=1] run tag @e[type=#helper:hostiles,tag=!helper.active,tag=!helper.horse,distance=..16,sort=nearest,limit=1] add helper.targeted

# Non-hunt: priority (attacker) then hunt_target then mobs — never random foe players
execute unless score @s helper_job matches 11 if entity @e[tag=helper.priority_target,distance=..48,limit=1] run tag @e[tag=helper.priority_target,distance=..48,sort=nearest,limit=1] add helper.targeted
execute unless score @s helper_job matches 11 unless entity @e[tag=helper.targeted,limit=1] if entity @a[tag=helper.hunt_target,distance=..48,limit=1] run tag @a[tag=helper.hunt_target,limit=1] add helper.targeted
execute unless score @s helper_job matches 11 unless entity @e[tag=helper.targeted,limit=1] as @a[tag=helper.my_owner,limit=1] at @s if entity @e[type=#helper:hostiles,tag=!helper.active,tag=!helper.horse,distance=..16,limit=1] run tag @e[type=#helper:hostiles,tag=!helper.active,tag=!helper.horse,distance=..16,sort=nearest,limit=1] add helper.targeted

execute if entity @e[tag=helper.targeted,limit=1] run scoreboard players set #owner_threat helper_config 1
