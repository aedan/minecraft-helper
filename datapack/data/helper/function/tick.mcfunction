# Main tick

scoreboard players add #golem_clock helper_config 1
execute if score #golem_clock helper_config matches 5.. run function helper:golem/check_structures
execute if score #golem_clock helper_config matches 5.. run scoreboard players set #golem_clock helper_config 0

execute as @e[tag=helper.active] at @s run function helper:helper_tick

# Owner lifecycle: keep helper locatable, recall, death→respawn
execute as @a[scores={helper_want=1}] run function helper:lifecycle/owner_tick
execute as @a[scores={helper_respawn_cd=1..}] run scoreboard players remove @s helper_respawn_cd 1

execute as @a[scores={helper_cmd=1}] at @s run function helper:cmd_stay
execute as @a[scores={helper_cmd=2}] at @s run function helper:cmd_fetch
execute as @a[scores={helper_cmd=3}] at @s run function helper:cmd_watch
execute as @a[scores={helper_cmd=4}] at @s run function helper:cmd_set_base
execute as @a[scores={helper_cmd=5}] at @s run function helper:cmd_despawn
execute as @a[scores={helper_cmd=6}] at @s run function helper:cmd_golem_help
execute as @a[scores={helper_cmd=7}] at @s run function helper:cmd_here
execute as @a[scores={helper_cmd=8}] at @s run function helper:cmd_private_help
execute as @a[scores={helper_cmd=9}] at @s run function helper:cmd_private_order
execute as @a[scores={helper_cmd=1..}] run scoreboard players set @s helper_cmd 0
execute as @a run scoreboard players enable @s helper_cmd
# /trigger tom — short private-order dialog (vanilla /msg is not logged)
execute as @a[scores={tom=1..}] at @s run function helper:cmd_private_order
execute as @a[scores={tom=1..}] run scoreboard players set @s tom 0
execute as @a run scoreboard players enable @s tom
