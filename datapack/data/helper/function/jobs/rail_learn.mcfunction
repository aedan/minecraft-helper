# Learn owner rail pattern near the owner (as/at owner). Writes scores onto helper.rail_me.
# helper_gkind lane mask: 1=left(^-1) 2=center 4=right(^+1). Dual sides = 5.
# helper_gt1 = normals between powered (0 = no powered cycle; all helper_gtype).
# helper_gt2 = phase (# normals since last powered at tip).
# helper_gt3 = torch: 0=none 1=center floor only 2=wall/outer only 3=both.
# Center wins over wall when both seen (do not invent walls from polluted samples).
# helper_gtype = normal segment rail type (0=rail) unless brain forced a single type.

scoreboard players set #rail_L helper_config 0
scoreboard players set #rail_C helper_config 0
scoreboard players set #rail_R helper_config 0
scoreboard players set #rail_pow helper_config 0
scoreboard players set #rail_period helper_config 0
scoreboard players set #rail_gap helper_config 0
scoreboard players set #rail_gaps helper_config 0
scoreboard players set #rail_torch helper_config 0
scoreboard players set #rail_torch_c helper_config 0
scoreboard players set #rail_torch_w helper_config 0
scoreboard players set #rail_phase helper_config 0
scoreboard players set #rail_lane helper_config 0

# Feet + BACKWARD first (owner's demonstrated work is usually behind/at feet)
function helper:jobs/rail_learn_sample
scoreboard players set #rail_scan helper_config 0
execute positioned ^ ^ ^-1 run function helper:jobs/rail_learn_back

# Forward: more presence (+ period if rails continue ahead)
scoreboard players set #rail_scan helper_config 0
scoreboard players set #rail_gap helper_config 0
execute positioned ^ ^ ^1 run function helper:jobs/rail_learn_fwd

# --- Lanes ---
scoreboard players set #rail_mask helper_config 0
execute if score #rail_L helper_config matches 3.. run scoreboard players add #rail_mask helper_config 1
execute if score #rail_C helper_config matches 3.. run scoreboard players add #rail_mask helper_config 2
execute if score #rail_R helper_config matches 3.. run scoreboard players add #rail_mask helper_config 4

# Prefer dual sides over center when both sides clearly present
execute if score #rail_L helper_config matches 3.. if score #rail_R helper_config matches 3.. run scoreboard players set #rail_mask helper_config 5

# Soft fallback: any side hits → sides; both sides even with low counts
execute if score #rail_L helper_config matches 1.. if score #rail_R helper_config matches 1.. run scoreboard players set #rail_mask helper_config 5
execute if score #rail_mask helper_config matches 0 if score #rail_L helper_config matches 1.. run scoreboard players set #rail_mask helper_config 1
execute if score #rail_mask helper_config matches 0 if score #rail_R helper_config matches 1.. run scoreboard players set #rail_mask helper_config 4
execute if score #rail_mask helper_config matches 0 if score #rail_C helper_config matches 1.. run scoreboard players set #rail_mask helper_config 2
execute if score #rail_mask helper_config matches 0 run scoreboard players set #rail_mask helper_config 2

# Period only if we saw powered and a positive gap
execute unless score #rail_period helper_config matches 1..32 run scoreboard players set #rail_period helper_config 0
execute if score #rail_pow helper_config matches 0 run scoreboard players set #rail_period helper_config 0

# Phase from tip going backward
scoreboard players set #rail_phase helper_config 0
scoreboard players set #rail_scan helper_config 0
function helper:jobs/rail_learn_phase
execute if score #rail_period helper_config matches 1.. if score #rail_phase helper_config > #rail_period helper_config run scoreboard players operation #rail_phase helper_config = #rail_period helper_config

# Apply onto helper
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_gkind = #rail_mask helper_config
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_gt1 = #rail_period helper_config
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_gt2 = #rail_phase helper_config
# Combine torch flags: center-only=1, wall-only=2, both=3. Prefer center-only when center present.
scoreboard players set #rail_torch helper_config 0
execute if score #rail_torch_c helper_config matches 1 run scoreboard players set #rail_torch helper_config 1
execute if score #rail_torch_c helper_config matches 0 if score #rail_torch_w helper_config matches 1 run scoreboard players set #rail_torch helper_config 2
execute if score #rail_torch_c helper_config matches 1 if score #rail_torch_w helper_config matches 1 run scoreboard players set #rail_torch helper_config 1
execute as @e[tag=helper.rail_me,limit=1] run scoreboard players operation @s helper_gt3 = #rail_torch helper_config

# Brain forced specialty type → no period/torch cycle
execute if score #brain_rail helper_config matches 11..13 as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt1 0
execute if score #brain_rail helper_config matches 11..13 as @e[tag=helper.rail_me,limit=1] run scoreboard players set @s helper_gt3 0

# Mark whether this scan produced a usable observed pattern (sides/center + period or plain)
scoreboard players set #rail_observed helper_config 0
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 1..7 if score @s helper_gt1 matches 1.. run scoreboard players set #rail_observed helper_config 1
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 1..7 if score @s helper_gt1 matches 0 if score #rail_L helper_config matches 1.. run scoreboard players set #rail_observed helper_config 1
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 1..7 if score @s helper_gt1 matches 0 if score #rail_R helper_config matches 1.. run scoreboard players set #rail_observed helper_config 1
execute as @e[tag=helper.rail_me,limit=1] if score @s helper_gkind matches 1..7 if score @s helper_gt1 matches 0 if score #rail_C helper_config matches 1.. run scoreboard players set #rail_observed helper_config 1

# Save successful observation to storage cache
execute if score #rail_observed helper_config matches 1 run function helper:jobs/rail_pattern_save

# If scan found lanes but no period, keep lanes/torch from scan (do not invent period)
# If scan found almost nothing, restore last observed cache (still from world, just prior)
execute if score #rail_observed helper_config matches 0 if data storage helper:rail_pattern ok run function helper:jobs/rail_pattern_restore
execute if score #rail_observed helper_config matches 0 if data storage helper:rail_pattern ok run scoreboard players set #rail_observed helper_config 2
