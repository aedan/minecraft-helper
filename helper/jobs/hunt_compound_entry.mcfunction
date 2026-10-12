# Walled-compound entry near hunt target. Non-destructive first; dig wall ONLY as fallback.
# Order: 1) wooden doors/gates  2) buttons/levers for iron doors  3) climb over wall  4) dig one body corridor

execute unless entity @a[tag=helper.hunt_target,distance=..48,limit=1] run return 0

execute at @s facing entity @a[tag=helper.hunt_target,limit=1] feet run tp @s ~ ~ ~ ~ ~

# --- 1) Wooden doors / fence gates / trapdoors ---
function helper:jobs/hunt_open_door
execute at @s if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run function helper:move/forward_fast
execute at @s if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run return 0

# --- 2) Activate nearby buttons / levers (iron-door operators) ---
# Stone/wood buttons and levers within reach ahead or beside — set powered via replace/destroy+place is messy;
# pulse by setting block to their powered state where possible, else break-and-replace air then rely on door open check.
execute at @s if block ^ ^ ^1 #minecraft:buttons run setblock ^ ^ ^1 air destroy
execute at @s if block ^1 ^ ^ #minecraft:buttons run setblock ^1 ^ ^ air destroy
execute at @s if block ^-1 ^ ^ #minecraft:buttons run setblock ^-1 ^ ^ air destroy
execute at @s if block ^ ^1 ^1 #minecraft:buttons run setblock ^ ^1 ^1 air destroy
execute at @s if block ^ ^ ^1 minecraft:lever[powered=false] run setblock ^ ^ ^1 minecraft:lever[powered=true]
execute at @s if block ^1 ^ ^ minecraft:lever[powered=false] run setblock ^1 ^ ^ minecraft:lever[powered=true]
execute at @s if block ^-1 ^ ^ minecraft:lever[powered=false] run setblock ^-1 ^ ^ minecraft:lever[powered=true]
execute at @s if block ^ ^1 ^1 minecraft:lever[powered=false] run setblock ^ ^1 ^1 minecraft:lever[powered=true]
# Pressure plate underfoot / ahead — step on it
execute at @s if block ^ ^ ^1 #minecraft:pressure_plates run tp @s ^ ^ ^0.4
# If iron door now passable (open) or was destroyed open path — walk
execute at @s if block ^ ^ ^1 #minecraft:doors if block ^ ^ ^1 #helper:passable run function helper:move/forward_fast
# Iron door still closed after trying actuators: leave for climb/dig; do not dig yet
execute at @s if block ^ ^ ^1 minecraft:iron_door run scoreboard players set #iron_block helper_config 1

# --- 3) Way OVER the wall (climb/pillar onto top) ---
# If solid ahead but air 2–4 above and top is standable, climb up then forward
scoreboard players set #over helper_config 0
execute at @s unless block ^ ^ ^1 #helper:passable if block ^ ^2 ^1 #helper:passable if block ^ ^3 ^1 #helper:passable run scoreboard players set #over helper_config 1
execute if score #over helper_config matches 1 at @s unless block ~ ~2 ~ minecraft:bedrock unless block ~ ~2 ~ #helper:passable run setblock ~ ~2 ~ air destroy
execute if score #over helper_config matches 1 at @s unless block ~ ~3 ~ minecraft:bedrock unless block ~ ~3 ~ #helper:passable run setblock ~ ~3 ~ air destroy
execute if score #over helper_config matches 1 at @s if block ~ ~1 ~ #helper:passable if block ~ ~2 ~ #helper:passable run tp @s ~ ~1 ~
execute if score #over helper_config matches 1 at @s if block ^ ^ ^0.5 #helper:passable if block ^ ^1 ^0.5 #helper:passable run tp @s ^ ^ ^0.5
execute if score #over helper_config matches 1 at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable if block ^ ^2 ^1 #helper:passable run return 0

# Also try step onto wall top if ^ ^2 ^1 solid floor with headroom
execute at @s unless block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable if block ^ ^2 ^1 #helper:passable if block ^ ^2 ^ #helper:passable run tp @s ^ ^1 ^0.4
execute at @s if block ^ ^ ^0.4 #helper:passable if block ^ ^1 ^0.4 #helper:passable run return 0

# --- 4) FALLBACK: dig one 1x3 body corridor through the obstacle (close range only) ---
execute unless entity @a[tag=helper.hunt_target,distance=..28,limit=1] run function helper:jobs/hunt_unstuck
execute unless entity @a[tag=helper.hunt_target,distance=..28,limit=1] run return 0

# Only if still blocked after doors/buttons/climb
execute at @s if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run return 0

# Clear feet + head + margin BEFORE moving
execute at @s unless block ^ ^ ^1 minecraft:bedrock unless block ^ ^ ^1 minecraft:barrier unless block ^ ^ ^1 #helper:passable run setblock ^ ^ ^1 air destroy
execute at @s unless block ^ ^1 ^1 minecraft:bedrock unless block ^ ^1 ^1 minecraft:barrier unless block ^ ^1 ^1 #helper:passable run setblock ^ ^1 ^1 air destroy
execute at @s unless block ^ ^2 ^1 minecraft:bedrock unless block ^ ^2 ^1 minecraft:barrier unless block ^ ^2 ^1 #helper:passable run setblock ^ ^2 ^1 air destroy
# Move only into cleared corridor
execute at @s if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run tp @s ^ ^ ^0.7
execute as @e[type=item,distance=..2.5] run tp @s @e[tag=helper.self,limit=1]
function helper:jobs/hunt_unstuck
