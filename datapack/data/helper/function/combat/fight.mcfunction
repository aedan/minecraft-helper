# Face the target, then pick sword / strafe / bow by distance.
# During hunt (job 11): NEVER teleport onto the target — journey jobs handle approach.

execute at @s facing entity @e[tag=helper.targeted,limit=1] feet run tp @s ~ ~ ~ ~ ~

execute if score @s helper_on_horse matches 1 run function helper:horse/combat_steer

execute if entity @e[tag=helper.targeted,distance=..3] run function helper:combat/sword_attack
execute if entity @e[tag=helper.targeted,distance=3.01..9] run function helper:combat/mid_range
# Bow only with a clear passable ray. Sword/mid still run without LOS.
execute if entity @e[tag=helper.targeted,distance=9.01..24] run function helper:combat/los_check
execute if entity @e[tag=helper.targeted,distance=9.01..24] if score #los helper_config matches 1 run function helper:combat/bow_attack

execute if score @s helper_on_horse matches 0 if entity @e[tag=helper.targeted,distance=3.01..24] at @s facing entity @e[tag=helper.targeted,limit=1] feet run function helper:move/forward

# Close the gap on distant threats — walk/horse only during hunt; short snap OK when NOT hunting
execute if score @s helper_on_horse matches 0 if entity @e[tag=helper.targeted,distance=24.01..] at @s facing entity @e[tag=helper.targeted,limit=1] feet run function helper:move/forward_fast
execute unless score @s helper_job matches 11 if entity @e[tag=helper.targeted,distance=32.01..] at @e[tag=helper.targeted,limit=1] run tp @s ^ ^ ^-2
# Hunt: dig/walk instead of warp when still far inside fight()
execute if score @s helper_job matches 11 if entity @e[tag=helper.targeted,distance=24.01..] run function helper:jobs/hunt_compound_entry
execute if score @s helper_job matches 11 if entity @e[tag=helper.targeted,distance=24.01..] run function helper:jobs/hunt_overland
