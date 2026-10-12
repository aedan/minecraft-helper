# As owner: set dig length from #dig helper_config, force job 8.
# #dig_keep 1 = continue in place (further / keep digging) — do not teleport to the owner.
# #dig_store 1 = deposit broken blocks into a chest at the work face (not the job-6 wood dump).
# Keep-dig facing: corridor dig-face at the owner (memory/tunnel_axis), else the
# remembered helper_tunnel yaw, else owner yaw with pitch 0. Never a random pitch.
# If that facing is bedrock, try other horizontal diggable solids; else abort with no job.
function helper:id/assign
tag @s add helper.cmd
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run tag @s add helper.dig_me
execute unless entity @e[tag=helper.dig_me,limit=1] as @e[tag=helper.active,sort=nearest,limit=1] run tag @s add helper.dig_me
execute unless entity @e[tag=helper.dig_me,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You do not have a helper.","color":"red"}]
execute unless entity @e[tag=helper.dig_me,limit=1] run tag @s remove helper.cmd
execute unless entity @e[tag=helper.dig_me,limit=1] run return 0

scoreboard players set #dig_abort helper_config 0
scoreboard players set #pick helper_config -999

# New dig: stand where the owner stands, but never inside solid/bedrock.
execute unless score #dig_keep helper_config matches 1 at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable as @e[tag=helper.dig_me,limit=1] rotated as @a[tag=helper.cmd,limit=1] run tp @s ~ ~ ~ ~ 0
scoreboard players set #dig_badspot helper_config 0
execute unless score #dig_keep helper_config matches 1 at @s unless block ~ ~ ~ #helper:passable run scoreboard players set #dig_badspot helper_config 1
execute unless score #dig_keep helper_config matches 1 at @s if block ~ ~ ~ minecraft:bedrock run scoreboard players set #dig_badspot helper_config 1
execute if score #dig_badspot helper_config matches 1 run scoreboard players set #dig_abort helper_config 1
execute if score #dig_badspot helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Not digging — that spot is solid. Step into open tunnel and try again.","color":"yellow"}]

# Keep dig: stay put. Prefer the corridor's dig face over a casual look yaw.
execute if score #dig_abort helper_config matches 0 if score #dig_keep helper_config matches 1 at @s run function helper:memory/tunnel_axis
execute if score #dig_abort helper_config matches 0 if score #dig_keep helper_config matches 1 unless score #pick helper_config matches -180..180 if score @s helper_tunnel matches -180..180 run scoreboard players operation #pick helper_config = @s helper_tunnel
execute if score #dig_abort helper_config matches 0 if score #dig_keep helper_config matches 1 if score #pick helper_config matches -180..180 as @e[tag=helper.dig_me,limit=1] run function helper:jobs/dig_face_apply
execute if score #dig_abort helper_config matches 0 if score #dig_keep helper_config matches 1 unless score #pick helper_config matches -180..180 as @e[tag=helper.dig_me,limit=1] at @s rotated as @a[tag=helper.cmd,limit=1] run tp @s ~ ~ ~ ~ 0

execute if score #dig_abort helper_config matches 0 as @e[tag=helper.dig_me,limit=1] at @s run function helper:jobs/dig_avoid_bedrock
execute if score #dig_badspot helper_config matches 0 if score #dig_abort helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Not digging — bedrock is ahead in every direction.","color":"yellow"}]
execute if score #dig_abort helper_config matches 1 run tag @e[tag=helper.dig_me] remove helper.dig_me
execute if score #dig_abort helper_config matches 1 run scoreboard players set #dig_keep helper_config 0
execute if score #dig_abort helper_config matches 1 run scoreboard players set #dig_store helper_config 0
execute if score #dig_abort helper_config matches 1 run tag @s remove helper.cmd
execute if score #dig_abort helper_config matches 1 run return 0

execute as @e[tag=helper.dig_me,limit=1] run function helper:jobs/clear_work
execute as @e[tag=helper.dig_me,limit=1] run scoreboard players set @s helper_q1 0
execute as @e[tag=helper.dig_me,limit=1] run scoreboard players set @s helper_q2 0
execute as @e[tag=helper.dig_me,limit=1] run scoreboard players set @s helper_q3 0
execute as @e[tag=helper.dig_me,limit=1] run scoreboard players set @s helper_job 8
execute as @e[tag=helper.dig_me,limit=1] run scoreboard players operation @s helper_dig_left = #dig helper_config
execute as @e[tag=helper.dig_me,limit=1] unless score @s helper_dig_left matches 1.. run scoreboard players set @s helper_dig_left 16

execute if score #dig_store helper_config matches 1 as @e[tag=helper.dig_me,limit=1] run scoreboard players set @s helper_q1 1
execute if score #dig_store helper_config matches 1 run kill @e[type=marker,tag=helper.dig_chest]
execute if score #dig_store helper_config matches 1 as @e[tag=helper.dig_me,limit=1] at @s run function helper:jobs/dig_place_chest

execute if score #dig_keep helper_config matches 1 if score #dig_store helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Continuing the tunnel from here and storing drops in a chest.","color":"green"}]
execute if score #dig_keep helper_config matches 1 unless score #dig_store helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Continuing the tunnel from here.","color":"green"}]
execute unless score #dig_keep helper_config matches 1 if score #dig_store helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Digging straight and storing drops in a chest.","color":"green"}]
execute unless score #dig_keep helper_config matches 1 unless score #dig_store helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Digging straight.","color":"green"}]

scoreboard players set #dig_keep helper_config 0
scoreboard players set #dig_store helper_config 0
tag @e[tag=helper.dig_me] remove helper.dig_me
tag @s remove helper.cmd
