# Helper data pack load

scoreboard objectives add helper_config dummy
scoreboard objectives add helper_id dummy
scoreboard objectives add helper_mode dummy
scoreboard objectives add helper_sword dummy
scoreboard objectives add helper_bow dummy
scoreboard objectives add helper_dodge dummy
scoreboard objectives add helper_strafe dummy
scoreboard objectives add helper_hurt dummy
scoreboard objectives add helper_atk_cd dummy
scoreboard objectives add helper_on_horse dummy
scoreboard objectives add helper_owner_mounted dummy
scoreboard objectives add helper_moved dummy
scoreboard objectives add helper_stuck dummy
scoreboard objectives add helper_job dummy
scoreboard objectives add helper_q1 dummy
scoreboard objectives add helper_q2 dummy
scoreboard objectives add helper_q3 dummy
scoreboard objectives add helper_wood dummy
scoreboard objectives add helper_work_cd dummy
scoreboard objectives add helper_raid_idle dummy
scoreboard objectives add helper_no_tree dummy
scoreboard objectives add helper_gtype dummy
scoreboard objectives add helper_gkind dummy
scoreboard objectives add helper_gt1 dummy
scoreboard objectives add helper_gt2 dummy
scoreboard objectives add helper_gt3 dummy
scoreboard objectives add helper_hx dummy
scoreboard objectives add helper_hy dummy
scoreboard objectives add helper_hz dummy
scoreboard objectives add helper_fx dummy
scoreboard objectives add helper_fz dummy
scoreboard objectives add helper_chunk_cd dummy
scoreboard objectives add helper_bx dummy
scoreboard objectives add helper_by dummy
scoreboard objectives add helper_bz dummy
scoreboard objectives add helper_bfx dummy
scoreboard objectives add helper_bfz dummy
scoreboard objectives add helper_tier dummy
scoreboard objectives add helper_want dummy
scoreboard objectives add helper_missing dummy
scoreboard objectives add helper_recall dummy
scoreboard objectives add helper_respawn_cd dummy
scoreboard objectives add helper_cmd trigger
scoreboard objectives add helper_dig_left dummy
scoreboard objectives add helper_yaw dummy
# Owner situational memory: quantized look, position, tunnel dig-face yaw.
scoreboard objectives add helper_tunnel dummy
scoreboard objectives add helper_hunt_cd dummy
scoreboard objectives add helper_lz dummy
scoreboard objectives add helper_ly dummy
scoreboard objectives add helper_lx dummy
scoreboard objectives add helper_sz dummy
scoreboard objectives add helper_sy dummy
scoreboard objectives add helper_sx dummy
scoreboard objectives add helper_hunt_stuck dummy
scoreboard objectives add helper_hunt_miss dummy
scoreboard objectives add helper_tx dummy
scoreboard objectives add helper_ty dummy
scoreboard objectives add helper_tz dummy
# Mode switches (combat/apply_mode): stay_at_base overrides protect_follow.
scoreboard objectives add helper_stay dummy
scoreboard objectives add helper_pf dummy
# Fall-recovery counter and paused-job position (protect reflex preempts jobs).
scoreboard objectives add helper_fall dummy
scoreboard objectives add helper_wx dummy
scoreboard objectives add helper_wy dummy
scoreboard objectives add helper_wz dummy
scoreboard objectives add helper_wyaw dummy
scoreboard objectives add helper_wpitch dummy
# Used by trust/* but never created before.
scoreboard objectives add trust_level dummy
# /trigger tom (read by tick.mcfunction) was never created.
scoreboard objectives add tom trigger

execute unless score #next_id helper_config matches 1.. run scoreboard players set #next_id helper_config 0
scoreboard players set #golem_clock helper_config 0

team add helper
team modify helper friendlyFire false
team modify helper collisionRule never
team modify helper seeFriendlyInvisibles true
team modify helper nametagVisibility always
team modify helper color aqua

execute as @a run scoreboard players enable @s helper_cmd
execute as @a run scoreboard players enable @s tom
execute as @e[tag=helper.active] run team join helper @s
execute as @e[tag=helper.active] at @s run function helper:chunk/force_here
execute as @e[type=marker,tag=helper.base] at @s run forceload add ~ ~
execute as @a[scores={helper_want=1}] unless score @s helper_tier matches 1.. run scoreboard players set @s helper_tier 3
execute as @a[tag=helper.owner] unless score @s helper_want matches 1 run scoreboard players set @s helper_want 1
execute as @a[scores={helper_id=1..}] run function helper:lifecycle/sync_base_from_marker
execute as @a[scores={helper_id=1..}] run function helper:lifecycle/sync_tier_from_helper
execute as @a[tag=helper.owner] unless score @s helper_want matches 1 run scoreboard players set @s helper_want 1
execute as @e[tag=helper.active] run data merge entity @s {hide_description:1b,CustomNameVisible:1b,description:{text:""}}
execute as @e[tag=helper.active] unless score @s helper_job matches 0.. run scoreboard players set @s helper_job 0
execute as @e[tag=helper.active] unless score @s helper_q1 matches 0.. run scoreboard players set @s helper_q1 0
execute as @e[tag=helper.active] unless score @s helper_q2 matches 0.. run scoreboard players set @s helper_q2 0
execute as @e[tag=helper.active] unless score @s helper_q3 matches 0.. run scoreboard players set @s helper_q3 0
execute as @a if score @s helper_id matches 1.. run team join helper @s

# Re-assert bound CustomName after reload (summon default is Helper)
execute as @e[tag=helper.active] run function helper:lifecycle/apply_bound_name

tellraw @a[tag=helper.owner] [{"text":"[Helper] ","color":"aqua"},{"text":"AI Helper loaded. ","color":"green"},{"text":"Build a golem (stone / iron / netherite + pumpkin) or ","color":"gray"},{"text":"/function helper:cmd_golem_help","color":"yellow"}]
