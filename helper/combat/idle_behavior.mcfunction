# Idle behavior: no threats detected, return to base or follow owner based on mode

# Check current mode from scoreboard
execute if score #mode helper_config matches 1 run function helper:combat/idle_stay_home
execute if score #mode helper_config matches 2 run function helper:combat/idle_fetch
execute if score #mode helper_config matches 3 run function helper:combat/idle_watch_back
execute if score #mode helper_config matches 0 run function helper:combat/idle_default
