# As the caller, helper loaded. Interrupt work and warp the helper to the caller (job 1).
scoreboard players set #job helper_config 1
scoreboard players set #gtype helper_config 0
function helper:jobs/force
tag @s add helper.cmd
