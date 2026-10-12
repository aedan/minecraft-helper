# Args: {x,y,z}. "data modify ... set" reports success only when the value changes, so
# copying the snapshot over the live contents tells us whether they differ.
$execute unless block $(x) $(y) $(z) #helper:containers run return run scoreboard players add #org_bad helper_config 1
$execute if data block $(x) $(y) $(z) LootTable run return run scoreboard players add #org_bad helper_config 1
data modify storage helper:api org.cmp set value []
$data modify storage helper:api org.cmp set from block $(x) $(y) $(z) Items
execute store success score #org_chg helper_config run data modify storage helper:api org.cmp set from storage helper:api org.cur.c.items
execute if score #org_chg helper_config matches 1 run scoreboard players add #org_bad helper_config 1
