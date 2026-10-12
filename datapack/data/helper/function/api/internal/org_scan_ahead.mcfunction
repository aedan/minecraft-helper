# As/at the helper. Pick the cardinal facing, then scan the generated region in front.
execute store result score #org_ox helper_config run data get entity @s Pos[0]
execute store result score #org_oy helper_config run data get entity @s Pos[1]
execute store result score #org_oz helper_config run data get entity @s Pos[2]
execute store result score #org_yaw helper_config run data get entity @s Rotation[0]
scoreboard players set #org_360 helper_config 360
scoreboard players operation #org_yaw helper_config %= #org_360 helper_config
execute if score #org_yaw helper_config matches ..-1 run scoreboard players add #org_yaw helper_config 360
# 0 south (+z), 1 west (-x), 2 north (-z), 3 east (+x)
scoreboard players set #org_dir helper_config 0
execute if score #org_yaw helper_config matches 45..134 run scoreboard players set #org_dir helper_config 1
execute if score #org_yaw helper_config matches 135..224 run scoreboard players set #org_dir helper_config 2
execute if score #org_yaw helper_config matches 225..314 run scoreboard players set #org_dir helper_config 3
execute if score #org_dir helper_config matches 0 align xyz run function helper:api/internal/org_scan_ahead_0
execute if score #org_dir helper_config matches 1 align xyz run function helper:api/internal/org_scan_ahead_1
execute if score #org_dir helper_config matches 2 align xyz run function helper:api/internal/org_scan_ahead_2
execute if score #org_dir helper_config matches 3 align xyz run function helper:api/internal/org_scan_ahead_3
