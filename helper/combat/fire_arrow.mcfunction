# Fire an arrow from Tom's eyes toward helper.targeted.
# Mannequins ignore `anchored eyes` (eye height == feet), so we use an explicit
# ~ ~1.62 ~ offset. Spawn slightly ahead of the body so the arrow does not
# immediately collide and zero its Motion (26.3).

execute unless entity @e[tag=helper.targeted,limit=1] run return 0

kill @e[type=marker,tag=helper.eye]
kill @e[type=marker,tag=helper.fwd]
kill @e[type=marker,tag=helper.muzzle]

# Face the foe so local aiming and visuals match
execute at @s facing entity @e[tag=helper.targeted,limit=1] eyes run tp @s ~ ~ ~ ~ ~

# Eye height origin (player-like); aim point ~2.5 blocks toward target eyes
execute at @s run summon marker ~ ~1.62 ~ {Tags:["helper.eye"]}
execute at @s positioned ~ ~1.62 ~ facing entity @e[tag=helper.targeted,limit=1] eyes run summon marker ^ ^ ^2.5 {Tags:["helper.fwd"]}
execute unless entity @e[type=marker,tag=helper.fwd,limit=1] run return 0

# Muzzle just ahead of the chest/eyes so projectile clears the mannequin hitbox
execute at @s positioned ~ ~1.62 ~ facing entity @e[tag=helper.targeted,limit=1] eyes run summon marker ^ ^ ^0.5 {Tags:["helper.muzzle"]}
execute unless entity @e[type=marker,tag=helper.muzzle,limit=1] run return 0


# Hard LOS gate: do not spawn an arrow into solid blocks (walls / ceilings).
# Reuse combat los_check from eye height toward the target; abort if blocked.
function helper:combat/los_check
execute unless score #los helper_config matches 1 run kill @e[type=marker,tag=helper.eye]
execute unless score #los helper_config matches 1 run kill @e[type=marker,tag=helper.fwd]
execute unless score #los helper_config matches 1 run kill @e[type=marker,tag=helper.muzzle]
execute unless score #los helper_config matches 1 run return 0

# Extra muzzle-forward samples (los_check uses feet aim; catch low ceilings / corner walls)
execute at @e[type=marker,tag=helper.muzzle,limit=1] facing entity @e[tag=helper.targeted,limit=1] eyes unless block ^ ^ ^0.6 #helper:passable unless entity @e[tag=helper.targeted,distance=..1.2] run return 0
execute at @e[type=marker,tag=helper.muzzle,limit=1] facing entity @e[tag=helper.targeted,limit=1] eyes unless block ^ ^ ^1.2 #helper:passable unless entity @e[tag=helper.targeted,distance=..1.8] run return 0
execute at @e[type=marker,tag=helper.muzzle,limit=1] facing entity @e[tag=helper.targeted,limit=1] eyes unless block ^ ^ ^1.8 #helper:passable unless entity @e[tag=helper.targeted,distance=..2.4] run return 0
execute at @e[type=marker,tag=helper.muzzle,limit=1] facing entity @e[tag=helper.targeted,limit=1] eyes unless block ^ ^ ^2.4 #helper:passable unless entity @e[tag=helper.targeted,distance=..3.0] run return 0

# Motion = fwd - eye  (length ≈ 2.5 blocks/tick toward the target)
execute store result score #ax helper_config run data get entity @e[type=marker,tag=helper.eye,limit=1] Pos[0] 1000
execute store result score #ay helper_config run data get entity @e[type=marker,tag=helper.eye,limit=1] Pos[1] 1000
execute store result score #az helper_config run data get entity @e[type=marker,tag=helper.eye,limit=1] Pos[2] 1000
execute store result score #bx helper_config run data get entity @e[type=marker,tag=helper.fwd,limit=1] Pos[0] 1000
execute store result score #by helper_config run data get entity @e[type=marker,tag=helper.fwd,limit=1] Pos[1] 1000
execute store result score #bz helper_config run data get entity @e[type=marker,tag=helper.fwd,limit=1] Pos[2] 1000
scoreboard players operation #bx helper_config -= #ax helper_config
scoreboard players operation #by helper_config -= #ay helper_config
scoreboard players operation #bz helper_config -= #az helper_config

execute at @e[type=marker,tag=helper.muzzle,limit=1] run summon arrow ~ ~ ~ {Tags:["helper.arrow","helper.arrow_new"],pickup:0b,crit:1b,damage:4.0d}
data modify entity @e[type=arrow,tag=helper.arrow_new,limit=1] Owner set from entity @s UUID
execute store result entity @e[type=arrow,tag=helper.arrow_new,limit=1] Motion[0] double 0.001 run scoreboard players get #bx helper_config
execute store result entity @e[type=arrow,tag=helper.arrow_new,limit=1] Motion[1] double 0.001 run scoreboard players get #by helper_config
execute store result entity @e[type=arrow,tag=helper.arrow_new,limit=1] Motion[2] double 0.001 run scoreboard players get #bz helper_config
tag @e[type=arrow,tag=helper.arrow_new] remove helper.arrow_new

kill @e[type=marker,tag=helper.eye]
kill @e[type=marker,tag=helper.fwd]
kill @e[type=marker,tag=helper.muzzle]
