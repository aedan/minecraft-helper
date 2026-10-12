# Stay with the owner like a wolf/cat. Teleport if too far or stuck in a hole.
# Personal space widened so Helper does not crowd the owner's mining/swing arc.

# Too far: warp (was 12; now 24).
execute unless entity @a[tag=helper.my_owner,distance=..24] run function helper:follow/teleport_to_owner
execute unless entity @a[tag=helper.my_owner,distance=..24] run return 0

# Fallen in a hole / owner climbed: owner is several blocks above and not next to us.
execute store result score #oy helper_config run data get entity @a[tag=helper.my_owner,limit=1] Pos[1]
execute store result score #hy helper_config run data get entity @s Pos[1]
scoreboard players operation #dy helper_config = #oy helper_config
scoreboard players operation #dy helper_config -= #hy helper_config
execute if score #dy helper_config matches 4.. unless entity @a[tag=helper.my_owner,distance=..8] run function helper:follow/teleport_to_owner
execute if score #dy helper_config matches 4.. unless entity @a[tag=helper.my_owner,distance=..8] run return 0

# Stuck walking toward the owner for ~1 second.
execute if entity @a[tag=helper.my_owner,distance=12..] run scoreboard players add @s helper_stuck 1
execute if entity @a[tag=helper.my_owner,distance=..11] run scoreboard players set @s helper_stuck 0
execute if score @s helper_stuck matches 20.. run function helper:follow/teleport_to_owner
execute if score @s helper_stuck matches 20.. run return 0

execute if score @s helper_on_horse matches 1 run function helper:horse/follow_owner
execute if score @s helper_on_horse matches 1 run return 0

execute at @s facing entity @a[tag=helper.my_owner,limit=1] feet run tp @s ~ ~ ~ ~ ~
# Only close in when farther than 6; back off inside 4 (was approach at 2.5–4 / back at ..2).
execute if entity @a[tag=helper.my_owner,distance=8..] at @s run function helper:move/forward_fast
execute if entity @a[tag=helper.my_owner,distance=6..8] at @s run function helper:move/forward
execute if entity @a[tag=helper.my_owner,distance=..4] at @s run function helper:move/back
