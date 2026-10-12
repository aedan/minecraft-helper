# Snap helper yaw to nearest cardinal and pitch 0; store locked tunnel axis in helper_yaw.
# Call as the helper (after copying owner look). Do NOT re-face the owner later.
execute at @s run tp @s ~ ~ ~ ~ 0
scoreboard players set #rail_snap helper_config 0
execute at @s if entity @s[y_rotation=-45..45] run scoreboard players set #rail_snap helper_config 1
execute at @s if entity @s[y_rotation=45..135] run scoreboard players set #rail_snap helper_config 2
execute at @s if entity @s[y_rotation=135..180] run scoreboard players set #rail_snap helper_config 3
execute at @s if entity @s[y_rotation=-180..-135] run scoreboard players set #rail_snap helper_config 3
execute at @s if entity @s[y_rotation=-135..-45] run scoreboard players set #rail_snap helper_config 4
# Apply exactly one cardinal (default south if somehow unmatched)
execute if score #rail_snap helper_config matches 0 at @s run tp @s ~ ~ ~ 0 0
execute if score #rail_snap helper_config matches 1 at @s run tp @s ~ ~ ~ 0 0
execute if score #rail_snap helper_config matches 2 at @s run tp @s ~ ~ ~ 90 0
execute if score #rail_snap helper_config matches 3 at @s run tp @s ~ ~ ~ 180 0
execute if score #rail_snap helper_config matches 4 at @s run tp @s ~ ~ ~ -90 0
execute if score #rail_snap helper_config matches 0 run scoreboard players set @s helper_yaw 0
execute if score #rail_snap helper_config matches 1 run scoreboard players set @s helper_yaw 0
execute if score #rail_snap helper_config matches 2 run scoreboard players set @s helper_yaw 90
execute if score #rail_snap helper_config matches 3 run scoreboard players set @s helper_yaw 180
execute if score #rail_snap helper_config matches 4 run scoreboard players set @s helper_yaw -90
