# Ray from eye height toward the target. Sets #los helper_config to 1 only if clear.
# Mannequins ignore `anchored eyes` (eye height == feet), so a feet ray clips the
# floor and a 2.5-block entity radius sees mobs through one-block walls.
# This ray starts at ~ ~1.62 ~, aims at the target's eyes, and fails on the first
# non-passable block before the hitbox (see los_step).
scoreboard players set #los helper_config 0
scoreboard players set #los_step helper_config 0
execute unless entity @e[tag=helper.targeted,limit=1] run return 0
execute at @s positioned ~ ~1.62 ~ facing entity @e[tag=helper.targeted,limit=1] eyes positioned ^ ^ ^0.35 run function helper:combat/los_step
