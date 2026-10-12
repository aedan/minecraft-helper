# Args: {d:<dest container>, s:<dest slot>, f:<source container>, g:<source slot>, c:<count>}
# Copies the snapshot item (all components) and sets only Slot and count.
$scoreboard players set #org_s helper_config $(s)
$scoreboard players set #org_c helper_config $(c)
execute unless score #org_s helper_config matches 0..26 run return run scoreboard players add #org_bad helper_config 1
execute unless score #org_c helper_config matches 1..99 run return run scoreboard players add #org_bad helper_config 1
$execute if data storage helper:api org.out[$(d)][{Slot:$(s)b}] run return run scoreboard players add #org_bad helper_config 1
$execute store success score #org_ok helper_config run data modify storage helper:api org.out[$(d)] append from storage helper:api org.chests[$(f)].items[{Slot:$(g)b}]
execute if score #org_ok helper_config matches 0 run return run scoreboard players add #org_bad helper_config 1
$data modify storage helper:api org.out[$(d)][-1].Slot set value $(s)b
$data modify storage helper:api org.out[$(d)][-1].count set value $(c)
