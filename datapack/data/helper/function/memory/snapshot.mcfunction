# As the owner, at the owner. Lightweight shared memory (updated every helper tick
# and owner tick). Scores live on the owner:
#   helper_oyaw   — look yaw quantized to 4 cardinals (0 south, 90 west, 180 north, -90 east)
#   helper_ox/oy/oz — block position
#   helper_tunnel — dig-face yaw of the 2-tall corridor they are standing in, if any.
#                  Kept until a newer corridor overwrites it (unset means "no memory").
# Tunnel axis is the direction into the SOLID dig face (short side), not back down
# the open tunnel and not into bedrock. See memory/tunnel_axis.
execute store result score @s helper_ox run data get entity @s Pos[0] 1
execute store result score @s helper_oy run data get entity @s Pos[1] 1
execute store result score @s helper_oz run data get entity @s Pos[2] 1
execute store result score #yaw helper_config run data get entity @s Rotation[0] 1
scoreboard players set @s helper_oyaw 0
execute if score #yaw helper_config matches 45..134 run scoreboard players set @s helper_oyaw 90
execute if score #yaw helper_config matches 135..180 run scoreboard players set @s helper_oyaw 180
execute if score #yaw helper_config matches -180..-135 run scoreboard players set @s helper_oyaw 180
execute if score #yaw helper_config matches -134..-45 run scoreboard players set @s helper_oyaw -90
# Only refresh the tunnel axis while standing in a 2-tall passable corridor.
execute if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run function helper:memory/tunnel_axis
