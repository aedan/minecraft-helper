# As the helper, same facing as the snapshot. #pat_base = blocks along the facing from the
# snapshot origin, if the helper is on that line (same height, no sideways offset).
execute store result score #pat_dx helper_config run data get entity @s Pos[0]
execute store result score #pat_dy helper_config run data get entity @s Pos[1]
execute store result score #pat_dz helper_config run data get entity @s Pos[2]
execute store result score #pat_t helper_config run data get storage helper:api pattern.origin.x
scoreboard players operation #pat_dx helper_config -= #pat_t helper_config
execute store result score #pat_t helper_config run data get storage helper:api pattern.origin.y
scoreboard players operation #pat_dy helper_config -= #pat_t helper_config
execute store result score #pat_t helper_config run data get storage helper:api pattern.origin.z
scoreboard players operation #pat_dz helper_config -= #pat_t helper_config
execute unless score #pat_dy helper_config matches 0 run return 0
# south (+z) / north (-z): sideways is x
execute if score #pat_dir helper_config matches 0 if score #pat_dx helper_config matches 0 run scoreboard players operation #pat_base helper_config = #pat_dz helper_config
execute if score #pat_dir helper_config matches 2 if score #pat_dx helper_config matches 0 run scoreboard players operation #pat_base helper_config -= #pat_dz helper_config
# west (-x) / east (+x): sideways is z
execute if score #pat_dir helper_config matches 1 if score #pat_dz helper_config matches 0 run scoreboard players operation #pat_base helper_config -= #pat_dx helper_config
execute if score #pat_dir helper_config matches 3 if score #pat_dz helper_config matches 0 run scoreboard players operation #pat_base helper_config = #pat_dx helper_config
