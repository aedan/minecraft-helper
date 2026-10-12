# Job 15: walk the learned rail axis and replace missing rails only.
# A gap is an air/passable lane cell with a solid floor and rails on BOTH sides
# within 8 blocks. Empty tunnel past the last rail is not extended (that is lay_rails).
# Phase (normal vs powered) comes from rail_learn / rail_resync_phase, same as lay_rails_place.
# Does not place torches or cobble bridges.
execute unless score @s helper_dig_left matches 1.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Done repairing rails (length limit).","color":"green"}]
execute unless score @s helper_dig_left matches 1.. run function helper:jobs/clear_work
execute unless score @s helper_dig_left matches 1.. run function helper:jobs/done
execute unless score @s helper_dig_left matches 1.. run return 0

function helper:jobs/rail_facing_restore
execute unless score @s helper_gkind matches 1..7 run scoreboard players set @s helper_gkind 2

function helper:jobs/repair_rails_fill
function helper:jobs/repair_rails_ahead

scoreboard players set #rail_step helper_config 0
execute if score #track_ahead helper_config matches 1 at @s unless block ^ ^-1 ^1 #helper:passable if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run scoreboard players set #rail_step helper_config 1
execute if score #track_ahead helper_config matches 1 if score #rail_step helper_config matches 0 at @s unless block ^ ^-2 ^1 #helper:passable if block ^ ^-1 ^1 #helper:passable if block ^ ^ ^1 #helper:passable run scoreboard players set #rail_step helper_config 2
execute if score #track_ahead helper_config matches 1 if score #rail_step helper_config matches 0 at @s unless block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable if block ^ ^2 ^1 #helper:passable run scoreboard players set #rail_step helper_config 3

execute if score #rail_step helper_config matches 1 at @s run tp @s ^ ^ ^1
execute if score #rail_step helper_config matches 2 at @s run tp @s ^ ^-1 ^1
execute if score #rail_step helper_config matches 3 at @s run tp @s ^ ^1 ^1
# Advance phase only. Do not call lay_rails_advance_phase — its powered verify
# aborts the whole job when a gap fill is not a fresh dual powered pair.
execute if score #rail_step helper_config matches 1..3 run scoreboard players set #rail_place_pow helper_config 0
execute if score #rail_step helper_config matches 1..3 if score @s helper_gt1 matches 1.. if score @s helper_gt2 >= @s helper_gt1 run scoreboard players set #rail_place_pow helper_config 1
execute if score #rail_step helper_config matches 1..3 if score #rail_place_pow helper_config matches 1 run scoreboard players set @s helper_gt2 0
execute if score #rail_step helper_config matches 1..3 if score #rail_place_pow helper_config matches 0 if score @s helper_gt1 matches 1.. run scoreboard players add @s helper_gt2 1
execute if score #rail_step helper_config matches 1..3 run scoreboard players remove @s helper_dig_left 1
execute if score #rail_step helper_config matches 1..3 run scoreboard players set @s helper_work_cd 0
execute if score #rail_step helper_config matches 1..3 run return 0

scoreboard players add @s helper_work_cd 1
execute if score @s helper_work_cd matches 8.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Done repairing rails — end of the track, or the way ahead is blocked.","color":"green"}]
execute if score @s helper_work_cd matches 8.. run function helper:jobs/clear_work
execute if score @s helper_work_cd matches 8.. run function helper:jobs/done
