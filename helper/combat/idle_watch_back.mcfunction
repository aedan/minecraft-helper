# Watch back: follow owner closely, stay within 4 blocks

# Check distance from owner
execute store result score #owner_dist helper_config run function helper:combat/calc_owner_distance

# If too far, chase owner
execute if score #owner_dist helper_config matches 5.. run function helper:combat/chase_owner

# If close, stand guard nearby
execute if score #owner_dist helper_config matches ..4 run function helper:combat/stand_guard
