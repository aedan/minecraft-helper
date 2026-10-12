# Spawn a horse if needed, then mount it.
execute if score #has_horse helper_config matches 0 run function helper:horse/spawn_and_ride
execute if score #has_horse helper_config matches 1 run function helper:horse/mount_existing
