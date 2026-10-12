# Runs as the newly summoned helper. Summoner is tagged helper.summoner.
scoreboard players operation @s helper_id = @a[tag=helper.summoner,limit=1] helper_id
scoreboard players set @s helper_mode 3
scoreboard players set @s helper_job 0
scoreboard players set @s helper_q1 0
scoreboard players set @s helper_q2 0
scoreboard players set @s helper_q3 0
scoreboard players set @s helper_wood 0
scoreboard players set @s helper_work_cd 0
scoreboard players set @s helper_raid_idle 0
scoreboard players set @s helper_no_tree 0
scoreboard players set @s helper_sword 0
scoreboard players set @s helper_bow 0
scoreboard players set @s helper_dodge 0
team join helper @s
team join helper @a[tag=helper.summoner,limit=1]
tag @a[tag=helper.summoner,limit=1] add helper.owner
scoreboard players set @a[tag=helper.summoner,limit=1] helper_want 1
scoreboard players set @a[tag=helper.summoner,limit=1] helper_missing 0
scoreboard players set @a[tag=helper.summoner,limit=1] helper_recall 0
data merge entity @s {Silent:1b,CustomNameVisible:1b,hide_description:1b,description:{text:""},PersistenceRequired:1b,NoAI:1b}

# Place base only when this owner has none yet (avoid relocating base on respawn).
scoreboard players set #has_base helper_config 0
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run scoreboard players set #has_base helper_config 1
execute if score @a[tag=helper.summoner,limit=1] helper_bx = @a[tag=helper.summoner,limit=1] helper_bx run scoreboard players set #has_base helper_config 1
execute if score #has_base helper_config matches 0 as @a[tag=helper.summoner,limit=1] at @s run function helper:combat/place_base_marker

function helper:chunk/force_here
execute store result score @a[tag=helper.summoner,limit=1] helper_hx run data get entity @s Pos[0]
execute store result score @a[tag=helper.summoner,limit=1] helper_hy run data get entity @s Pos[1]
execute store result score @a[tag=helper.summoner,limit=1] helper_hz run data get entity @s Pos[2]
tag @s remove helper.new

# Restore bound name after any summon/respawn recreate
function helper:lifecycle/apply_bound_name
