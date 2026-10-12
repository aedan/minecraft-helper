# Job 12: walk forward placing rails on learned lane offsets (not inventing a center line).
# helper_gtype: 0=rail 1=powered 2=detector 3=activator (normal segments)
# helper_gkind: lane mask 1=left 2=center 4=right (dual sides=5)
# helper_gt1: normals between powered (0=no cycle)
# helper_gt2: phase
# helper_gt3: torch (1=beside powered)
# helper_dig_left: remaining steps

# Length exhausted (default/cap) — not the same as tunnel ended mid-path.
execute unless score @s helper_dig_left matches 1.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Done laying rails (length limit). Say all the way to the end if you want me to continue until the tunnel ends.","color":"green"}]
execute unless score @s helper_dig_left matches 1.. run function helper:jobs/clear_work
execute unless score @s helper_dig_left matches 1.. run function helper:jobs/done
execute unless score @s helper_dig_left matches 1.. run return 0

execute unless score @s helper_gkind matches 1..7 run scoreboard players set @s helper_gkind 2

# Lock tunnel axis every tick so combat/idle cannot twist facing mid-job.
function helper:jobs/rail_facing_restore

scoreboard players set #rail_step helper_config 0

# 1) Flat: solid floor ahead + passable — place lanes ahead then step
execute at @s unless block ^ ^-1 ^1 #helper:passable if block ^ ^ ^1 #helper:passable run execute positioned ^ ^ ^1 run function helper:jobs/lay_rails_place_lanes
execute at @s unless block ^ ^-1 ^1 #helper:passable if block ^ ^ ^1 #helper:passable run scoreboard players set #rail_step helper_config 1

# 1b) Already railed flat ahead on an active lane (or dual-side center walkway)
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 1 if block ^-1 ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 3 if block ^-1 ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 5 if block ^-1 ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 7 if block ^-1 ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 4 if block ^1 ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 5 if block ^1 ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 6 if block ^1 ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 7 if block ^1 ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 2 if block ^ ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 3 if block ^ ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 6 if block ^ ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 7 if block ^ ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
# Dual sides: walk center even with no center rail
execute at @s if score #rail_step helper_config matches 0 if score @s helper_gkind matches 5 unless block ^ ^-1 ^1 #helper:passable if block ^ ^ ^1 #helper:passable run scoreboard players set #rail_step helper_config 1

# 2) Down-step
execute at @s if score #rail_step helper_config matches 0 unless block ^ ^-2 ^1 #helper:passable if block ^ ^-1 ^1 #helper:passable run execute positioned ^ ^-1 ^1 run function helper:jobs/lay_rails_place_lanes
execute at @s if score #rail_step helper_config matches 0 unless block ^ ^-2 ^1 #helper:passable if block ^ ^-1 ^1 #helper:passable run scoreboard players set #rail_step helper_config 2
execute at @s if score #rail_step helper_config matches 0 if block ^-1 ^-1 ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 2
execute at @s if score #rail_step helper_config matches 0 if block ^1 ^-1 ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 2
execute at @s if score #rail_step helper_config matches 0 if block ^ ^-1 ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 2

# 3) Up-step
execute at @s if score #rail_step helper_config matches 0 unless block ^ ^ ^1 #helper:passable unless block ^ ^ ^1 #minecraft:rails if block ^ ^1 ^1 #helper:passable run execute positioned ^ ^1 ^1 run function helper:jobs/lay_rails_place_lanes
execute at @s if score #rail_step helper_config matches 0 unless block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run scoreboard players set #rail_step helper_config 3
execute at @s if score #rail_step helper_config matches 0 if block ^-1 ^1 ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 3
execute at @s if score #rail_step helper_config matches 0 if block ^1 ^1 ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 3
execute at @s if score #rail_step helper_config matches 0 if block ^ ^1 ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 3

# Advance
execute if score #rail_step helper_config matches 1 at @s run tp @s ^ ^ ^1
execute if score #rail_step helper_config matches 2 at @s run tp @s ^ ^-1 ^1
execute if score #rail_step helper_config matches 3 at @s run tp @s ^ ^1 ^1
execute if score #rail_step helper_config matches 1..3 run function helper:jobs/lay_rails_advance_phase
execute if score #rail_step helper_config matches 1..3 run scoreboard players remove @s helper_dig_left 1
# Successful step clears gap patience
execute if score #rail_step helper_config matches 1..3 run scoreboard players set @s helper_work_cd 0

# 4) Brief floor gap: corridor continues (body+head air) but floor missing — bridge then step
execute at @s if score #rail_step helper_config matches 0 if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable if block ^ ^-1 ^1 #helper:passable run setblock ^ ^-1 ^1 minecraft:cobblestone keep
execute at @s if score #rail_step helper_config matches 0 unless block ^ ^-1 ^1 #helper:passable if block ^ ^ ^1 #helper:passable run execute positioned ^ ^ ^1 run function helper:jobs/lay_rails_place_lanes
execute at @s if score #rail_step helper_config matches 0 unless block ^ ^-1 ^1 #helper:passable if block ^ ^ ^1 #helper:passable run scoreboard players set #rail_step helper_config 1
execute if score #rail_step helper_config matches 1 at @s run tp @s ^ ^ ^1
execute if score #rail_step helper_config matches 1 run function helper:jobs/lay_rails_advance_phase
execute if score #rail_step helper_config matches 1 run scoreboard players remove @s helper_dig_left 1
execute if score #rail_step helper_config matches 1 run scoreboard players set @s helper_work_cd 0

# 5) True tunnel end only when no air corridor ahead for several blocks (solid wall / sealed),
#    with a few ticks of patience so a single awkward block does not abort.
execute if score #rail_step helper_config matches 0 run scoreboard players add @s helper_work_cd 1
# Corridor still open ahead (body or head air within 1..3) → keep patience, do not quit yet
scoreboard players set #rail_open helper_config 0
execute at @s if score #rail_step helper_config matches 0 if block ^ ^ ^1 #helper:passable run scoreboard players set #rail_open helper_config 1
execute at @s if score #rail_step helper_config matches 0 if block ^ ^1 ^1 #helper:passable run scoreboard players set #rail_open helper_config 1
execute at @s if score #rail_step helper_config matches 0 if block ^ ^ ^2 #helper:passable run scoreboard players set #rail_open helper_config 1
execute at @s if score #rail_step helper_config matches 0 if block ^ ^ ^3 #helper:passable run scoreboard players set #rail_open helper_config 1
execute at @s if score #rail_step helper_config matches 0 if block ^-1 ^ ^1 #minecraft:rails run scoreboard players set #rail_open helper_config 1
execute at @s if score #rail_step helper_config matches 0 if block ^1 ^ ^1 #minecraft:rails run scoreboard players set #rail_open helper_config 1
execute at @s if score #rail_step helper_config matches 0 if block ^ ^ ^1 #minecraft:rails run scoreboard players set #rail_open helper_config 1
# Soft wait while corridor looks open (bridge may need another tick / combat bump)
execute if score #rail_step helper_config matches 0 if score #rail_open helper_config matches 1 if score @s helper_work_cd matches ..12 run return 0
# Hard end: sealed ahead for several failed ticks, or long patience with no open corridor
execute if score #rail_step helper_config matches 0 if score @s helper_work_cd matches 8.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Stopped laying rails — tunnel ended.","color":"yellow"}]
execute if score #rail_step helper_config matches 0 if score @s helper_work_cd matches 8.. run function helper:jobs/clear_work
execute if score #rail_step helper_config matches 0 if score @s helper_work_cd matches 8.. run function helper:jobs/done
