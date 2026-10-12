# Long-range pursuit. NO teleport onto victim.
# Multi-modal chooser (fastest practical): rail → boat → horse → overland walk.
# Surface-first; no blind wall-dig. Dig-down only via overland when close+below.

# --- Detect current vehicle ---
scoreboard players set #in_boat helper_config 0
scoreboard players set #in_cart helper_config 0
execute on vehicle if entity @s[type=oak_boat] run scoreboard players set #in_boat helper_config 1
execute on vehicle if entity @s[type=minecart] run scoreboard players set #in_cart helper_config 1

# Leave horse before water / rail
execute at @s if block ~ ~ ~ minecraft:water if score @s helper_on_horse matches 1 run function helper:horse/despawn_horse
execute at @s if block ~ ~ ~ #minecraft:rails if score @s helper_on_horse matches 1 run function helper:horse/despawn_horse
execute at @s if block ~ ~-1 ~ #minecraft:rails if score @s helper_on_horse matches 1 run function helper:horse/despawn_horse

# ========== 1) RAIL (if on/near rails toward target) ==========
execute if score #in_cart helper_config matches 1 run function helper:jobs/hunt_rail
execute if score #in_cart helper_config matches 1 run return 0
# Board rails when standing on them or rails within 2 and target not in melee
execute if score #in_boat helper_config matches 0 if score @s helper_on_horse matches 0 unless entity @a[tag=helper.hunt_target,distance=..16,limit=1] at @s if block ~ ~ ~ #minecraft:rails run function helper:jobs/hunt_rail
execute if score #in_boat helper_config matches 0 if score @s helper_on_horse matches 0 unless entity @a[tag=helper.hunt_target,distance=..16,limit=1] at @s if block ~ ~-1 ~ #minecraft:rails run function helper:jobs/hunt_rail
execute on vehicle if entity @s[type=minecart] run scoreboard players set #in_cart helper_config 1
execute if score #in_cart helper_config matches 1 run return 0
# Walk onto nearby rail if it lies toward target (simple: rail within 3 in facing cone)
execute if score #in_boat helper_config matches 0 if score @s helper_on_horse matches 0 unless entity @a[tag=helper.hunt_target,distance=..16,limit=1] at @s facing entity @a[tag=helper.hunt_target,limit=1] feet if block ^ ^ ^2 #minecraft:rails run tp @s ^ ^ ^0.5
execute if score #in_boat helper_config matches 0 if score @s helper_on_horse matches 0 unless entity @a[tag=helper.hunt_target,distance=..16,limit=1] at @s facing entity @a[tag=helper.hunt_target,limit=1] feet if block ^ ^-1 ^2 #minecraft:rails run tp @s ^ ^ ^0.5

# ========== 2) BOAT (water) ==========
execute if score #in_boat helper_config matches 0 at @s if block ~ ~ ~ minecraft:water run function helper:jobs/hunt_boat
execute if score #in_boat helper_config matches 1 on vehicle at @s facing entity @a[tag=helper.hunt_target,limit=1] feet run tp @s ~ ~ ~ ~ ~
execute if score #in_boat helper_config matches 1 on vehicle at @s if block ^ ^ ^0.55 minecraft:water run tp @s ^ ^ ^0.55
execute if score #in_boat helper_config matches 1 on vehicle at @s if block ^ ^ ^0.55 #helper:passable run tp @s ^ ^ ^0.55
execute if score #in_boat helper_config matches 1 run function helper:jobs/hunt_unstuck
execute if score #in_boat helper_config matches 1 run return 0

# ========== 3) HORSE (far land, not water/rail) ==========
execute unless entity @a[tag=helper.hunt_target,distance=..32,limit=1] if score @s helper_on_horse matches 0 if score #in_boat helper_config matches 0 if score #in_cart helper_config matches 0 at @s unless block ~ ~ ~ minecraft:water unless block ~ ~ ~ #minecraft:rails unless block ~ ~-1 ~ #minecraft:rails run function helper:jobs/hunt_mount

# On horse: steer vehicle only — overland, NO wall dig. Step-up OK. Unstuck after.
execute if score @s helper_on_horse matches 1 on vehicle at @s facing entity @a[tag=helper.hunt_target,limit=1] feet run tp @s ~ ~ ~ ~ ~
execute if score @s helper_on_horse matches 1 on vehicle at @s if block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run tp @s ^ ^ ^0.55
execute if score @s helper_on_horse matches 1 on vehicle at @s unless block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable if block ^ ^1 ^ #helper:passable if block ^ ^2 ^0.55 #helper:passable run tp @s ^ ^1 ^0.55
# Horse blocked: try side passages (no dig)
execute if score @s helper_on_horse matches 1 on vehicle at @s unless block ^ ^ ^0.55 #helper:passable if block ^0.8 ^ ^0.4 #helper:passable run tp @s ^0.6 ^ ^0.3
execute if score @s helper_on_horse matches 1 on vehicle at @s unless block ^ ^ ^0.55 #helper:passable if block ^-0.8 ^ ^0.4 #helper:passable run tp @s ^-0.6 ^ ^0.3
# If rails under horse while mounted far — dismount to take rail
execute if score @s helper_on_horse matches 1 at @s if block ~ ~-1 ~ #minecraft:rails run function helper:horse/despawn_horse
execute if score @s helper_on_horse matches 1 run function helper:jobs/hunt_unstuck
execute if score @s helper_on_horse matches 1 run return 0

# ========== 4) ON FOOT — surface-first overland ==========
function helper:jobs/hunt_overland
function helper:jobs/hunt_unstuck
