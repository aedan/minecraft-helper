# Place or move this player's base marker. Executed as/at the owner (or desired spot).
# Caller tags the owner as helper.summoner or helper.cmd.
execute as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run tag @s add helper.old_base
execute unless entity @a[tag=helper.summoner,limit=1] as @e[type=marker,tag=helper.base] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.old_base

# Drop forceload on the previous base chunk (player-stored), then kill old marker.
execute if entity @a[tag=helper.summoner,limit=1] if score @a[tag=helper.summoner,limit=1] helper_bfx = @a[tag=helper.summoner,limit=1] helper_bfx store result storage helper:chunk x int 1 run scoreboard players get @a[tag=helper.summoner,limit=1] helper_bfx
execute if entity @a[tag=helper.summoner,limit=1] if score @a[tag=helper.summoner,limit=1] helper_bfx = @a[tag=helper.summoner,limit=1] helper_bfx store result storage helper:chunk z int 1 run scoreboard players get @a[tag=helper.summoner,limit=1] helper_bfz
execute if entity @a[tag=helper.summoner,limit=1] if score @a[tag=helper.summoner,limit=1] helper_bfx = @a[tag=helper.summoner,limit=1] helper_bfx run function helper:chunk/unforce_at with storage helper:chunk
execute unless entity @a[tag=helper.summoner,limit=1] if score @a[tag=helper.cmd,limit=1] helper_bfx = @a[tag=helper.cmd,limit=1] helper_bfx store result storage helper:chunk x int 1 run scoreboard players get @a[tag=helper.cmd,limit=1] helper_bfx
execute unless entity @a[tag=helper.summoner,limit=1] if score @a[tag=helper.cmd,limit=1] helper_bfx = @a[tag=helper.cmd,limit=1] helper_bfx store result storage helper:chunk z int 1 run scoreboard players get @a[tag=helper.cmd,limit=1] helper_bfz
execute unless entity @a[tag=helper.summoner,limit=1] if score @a[tag=helper.cmd,limit=1] helper_bfx = @a[tag=helper.cmd,limit=1] helper_bfx run function helper:chunk/unforce_at with storage helper:chunk

kill @e[type=marker,tag=helper.old_base]
summon marker ~ ~ ~ {Tags:["helper.base","helper.base_new"],PersistenceRequired:1b}
execute if entity @a[tag=helper.summoner,limit=1] run scoreboard players operation @e[type=marker,tag=helper.base_new,limit=1] helper_id = @a[tag=helper.summoner,limit=1] helper_id
execute unless entity @a[tag=helper.summoner,limit=1] run scoreboard players operation @e[type=marker,tag=helper.base_new,limit=1] helper_id = @a[tag=helper.cmd,limit=1] helper_id

# Persist base coords on the owner and keep that chunk loaded forever (until base moves).
execute if entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.summoner,limit=1] helper_bx run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[0]
execute if entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.summoner,limit=1] helper_by run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[1]
execute if entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.summoner,limit=1] helper_bz run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[2]
execute if entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.summoner,limit=1] helper_bfx run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[0]
execute if entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.summoner,limit=1] helper_bfz run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[2]
execute unless entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.cmd,limit=1] helper_bx run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[0]
execute unless entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.cmd,limit=1] helper_by run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[1]
execute unless entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.cmd,limit=1] helper_bz run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[2]
execute unless entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.cmd,limit=1] helper_bfx run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[0]
execute unless entity @a[tag=helper.summoner,limit=1] store result score @a[tag=helper.cmd,limit=1] helper_bfz run data get entity @e[type=marker,tag=helper.base_new,limit=1] Pos[2]

execute at @e[type=marker,tag=helper.base_new,limit=1] run forceload add ~ ~
tag @e[type=marker,tag=helper.base_new] remove helper.base_new
