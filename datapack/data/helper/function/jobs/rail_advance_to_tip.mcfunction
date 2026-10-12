# As/at the helper, facing the unfinished tip (rail_orient_tip). Walk forward over already
# laid track to the frontier so laying continues the line instead of starting behind it.
# Stops at the first cell with no rail in the left/center/right lane, at an obstruction,
# or after 512 steps (#rail_scan, reset by the caller). Was called but never existed.
scoreboard players add #rail_scan helper_config 1
execute if score #rail_scan helper_config matches 512.. run return 0
execute unless block ^-1 ^ ^1 #minecraft:rails unless block ^ ^ ^1 #minecraft:rails unless block ^1 ^ ^1 #minecraft:rails run return 0
execute unless block ^ ^1 ^1 #helper:passable run return 0
execute unless block ^ ^ ^1 #helper:passable unless block ^ ^ ^1 #minecraft:rails run return 0
tp @s ^ ^ ^1
execute at @s run function helper:jobs/rail_advance_to_tip
