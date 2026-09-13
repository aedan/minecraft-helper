# Stay home: patrol around base, return if strayed more than 32 blocks

# Check distance from base
execute store result score #base_dist helper_config run function helper:combat/calc_base_distance

# If strayed too far, return to base
execute if score #base_dist helper_config matches 33.. run function helper:combat/return_to_base

# If close to base, wander within 16-block radius
execute if score #base_dist helper_config matches ..16 run function helper:combat/patrol_base

# If in between, stay put
execute if score #base_dist helper_config matches 17..32 run function helper:combat/idle_wait
