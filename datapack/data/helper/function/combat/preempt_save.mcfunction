# As a helper whose job is being interrupted to defend the owner. Remember where it was
# working (x100, so coordinates up to +-21,000,000) so combat/preempt_restore can put it back.
tag @s add helper.preempted
execute store result score @s helper_wx run data get entity @s Pos[0] 100
execute store result score @s helper_wy run data get entity @s Pos[1] 100
execute store result score @s helper_wz run data get entity @s Pos[2] 100
execute store result score @s helper_wyaw run data get entity @s Rotation[0] 100
execute store result score @s helper_wpitch run data get entity @s Rotation[1] 100
