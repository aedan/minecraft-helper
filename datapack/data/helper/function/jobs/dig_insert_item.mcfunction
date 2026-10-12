# As an item entity, at the dig chest. Merge into a matching slot or append.
scoreboard players set #ins helper_config 0
data modify storage helper:digdrop in set from entity @s Item
function helper:jobs/dig_merge_scan
execute if score #ins helper_config matches 1 run kill @s
