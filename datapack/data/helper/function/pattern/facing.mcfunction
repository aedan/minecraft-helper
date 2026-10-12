# As an entity. #pat_dir = cardinal facing from its yaw: 0 south, 1 west, 2 north, 3 east.
execute store result score #pat_yaw helper_config run data get entity @s Rotation[0]
scoreboard players set #pat_360 helper_config 360
scoreboard players operation #pat_yaw helper_config %= #pat_360 helper_config
execute if score #pat_yaw helper_config matches ..-1 run scoreboard players add #pat_yaw helper_config 360
scoreboard players set #pat_dir helper_config 0
execute if score #pat_yaw helper_config matches 45..134 run scoreboard players set #pat_dir helper_config 1
execute if score #pat_yaw helper_config matches 135..224 run scoreboard players set #pat_dir helper_config 2
execute if score #pat_yaw helper_config matches 225..314 run scoreboard players set #pat_dir helper_config 3
