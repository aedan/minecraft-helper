# SURFACE-FIRST pathing toward helper.hunt_target. No blind wall-digging.
# Decision order:
#   1) Face target  2) Open doors  3) Walk existing air corridor
#   4) Step-up terrain  5) Strafe around (left/right passages)
#   6) Climb if target above  7) Maze breakout if stuck looping
#   8) Dig DOWN only if close + target beneath (via hunt_dig_down)
# Never move into uncleared solid blocks.

execute unless entity @a[tag=helper.hunt_target,limit=1] run return 0

# Track progress vs last fingerprint (updated below before movement)
scoreboard players set #moved helper_config 0
execute store result score #cx helper_config run data get entity @s Pos[0]
execute store result score #cy helper_config run data get entity @s Pos[1]
execute store result score #cz helper_config run data get entity @s Pos[2]
execute unless score #cx helper_config = @s helper_sx run scoreboard players set #moved helper_config 1
execute unless score #cz helper_config = @s helper_sz run scoreboard players set #moved helper_config 1
execute unless score #cy helper_config = @s helper_sy run scoreboard players set #moved helper_config 1
execute if score #moved helper_config matches 1 run scoreboard players set @s helper_hunt_stuck 0
execute if score #moved helper_config matches 0 run scoreboard players add @s helper_hunt_stuck 1
# Fingerprint current block for next tick (before we move this tick)
scoreboard players operation @s helper_sx = #cx helper_config
scoreboard players operation @s helper_sy = #cy helper_config
scoreboard players operation @s helper_sz = #cz helper_config

# Face the designated target only
execute at @s facing entity @a[tag=helper.hunt_target,limit=1] feet run tp @s ~ ~ ~ ~ ~

# Maze timeout (~3s at 20tps): climb out / surface instead of searching forever
execute if score @s helper_hunt_stuck matches 60.. run function helper:jobs/hunt_surface_breakout
execute if score @s helper_hunt_stuck matches 60.. run return 0

# Prefer doors / existing openings
function helper:jobs/hunt_open_door

# 1) Existing passageway ahead (feet+head) → walk; never enter solid
execute at @s if block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run function helper:move/forward_fast
execute at @s if block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run return 0

# 2) Natural step-up (1-block hill) if head clearance OK
execute at @s unless block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable if block ^ ^1 ^ #helper:passable if block ^ ^2 ^0.55 #helper:passable run tp @s ^ ^1 ^0.55
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable if block ^ ^ ^0.55 #helper:passable run return 0

# 3) Strafe around obstacle — follow land / side passages (check left then forward)
scoreboard players set #sided helper_config 0
execute at @s if block ^0.7 ^ ^ #helper:passable if block ^0.7 ^1 ^ #helper:passable if block ^0.7 ^ ^0.55 #helper:passable if block ^0.7 ^1 ^0.55 #helper:passable run scoreboard players set #sided helper_config 1
execute if score #sided helper_config matches 1 at @s run tp @s ^0.55 ^ ^
execute if score #sided helper_config matches 1 run return 0
execute at @s if block ^-0.7 ^ ^ #helper:passable if block ^-0.7 ^1 ^ #helper:passable if block ^-0.7 ^ ^0.55 #helper:passable if block ^-0.7 ^1 ^0.55 #helper:passable run scoreboard players set #sided helper_config 2
execute if score #sided helper_config matches 2 at @s run tp @s ^-0.55 ^ ^
execute if score #sided helper_config matches 2 run return 0

# 4) Vertical: climb if target above; dig-down only if close + below
execute store result score #ty helper_config run data get entity @a[tag=helper.hunt_target,limit=1] Pos[1]
execute store result score #hy helper_config run data get entity @s Pos[1]
scoreboard players operation #dy helper_config = #ty helper_config
scoreboard players operation #dy helper_config -= #hy helper_config

# Target above → climb through air / clear ceiling only enough to step up (not horizontal dig)
execute if score #dy helper_config matches 3.. at @s unless block ~ ~2 ~ minecraft:bedrock unless block ~ ~2 ~ minecraft:barrier unless block ~ ~2 ~ #helper:passable run setblock ~ ~2 ~ air destroy
execute if score #dy helper_config matches 3.. at @s if block ~ ~1 ~ #helper:passable if block ~ ~2 ~ #helper:passable run tp @s ~ ~1 ~
execute if score #dy helper_config matches 3.. run function helper:jobs/hunt_unstuck
execute if score #dy helper_config matches 3.. run return 0

# Target below + close + no side passage found → targeted dig down
execute if score #dy helper_config matches ..-2 if entity @a[tag=helper.hunt_target,distance=..32,limit=1] run function helper:jobs/hunt_dig_down
execute if score #dy helper_config matches ..-2 if entity @a[tag=helper.hunt_target,distance=..32,limit=1] run return 0

# 5) Soft heading change when blocked at range (try 45° left) — still no wall dig
execute at @s facing entity @a[tag=helper.hunt_target,limit=1] feet run tp @s ~ ~ ~ ~-45 ~
function helper:jobs/hunt_open_door
execute at @s if block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run function helper:move/forward_fast
execute at @s if block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run return 0
execute at @s facing entity @a[tag=helper.hunt_target,limit=1] feet run tp @s ~ ~ ~ ~45 ~
function helper:jobs/hunt_open_door
execute at @s if block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run function helper:move/forward_fast

# If still blocked far away: mark stuck higher so maze breakout triggers sooner; DO NOT dig walls
execute at @s unless block ^ ^ ^0.55 #helper:passable run scoreboard players add @s helper_hunt_stuck 5

function helper:jobs/hunt_unstuck
