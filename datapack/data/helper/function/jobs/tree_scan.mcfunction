scoreboard players set #found helper_config 0
execute positioned ~ ~-1 ~ run function helper:jobs/tree_scan_xz
execute if score #found helper_config matches 0 positioned ~ ~ ~ run function helper:jobs/tree_scan_xz
execute if score #found helper_config matches 0 positioned ~ ~1 ~ run function helper:jobs/tree_scan_xz
execute if score #found helper_config matches 0 positioned ~ ~2 ~ run function helper:jobs/tree_scan_xz
execute if score #found helper_config matches 0 positioned ~ ~3 ~ run function helper:jobs/tree_scan_xz
execute if score #found helper_config matches 0 positioned ~ ~4 ~ run function helper:jobs/tree_scan_xz
