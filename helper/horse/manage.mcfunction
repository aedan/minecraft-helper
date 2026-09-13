# Horse system: spawn on demand, max stats, armor, despawn when unused
# Horse is a tool for the helper, just like everything else

# Check if owner is on a horse
execute store result score #owner_on_horse helper_config run data get entity @a[limit=1] Vehicle[0]

# If owner is on horse and helper doesn't have one, spawn horse
execute if score #owner_on_horse helper_config matches 1 unless entity @e[type=horse,tag=helper.horse,limit=1] run function helper:horse/spawn_horse

# If owner is NOT on horse and helper has a horse, despawn it
execute unless score #owner_on_horse helper_config matches 1 if entity @e[type=horse,tag=helper.horse,limit=1] run function helper:horse/despawn_horse
