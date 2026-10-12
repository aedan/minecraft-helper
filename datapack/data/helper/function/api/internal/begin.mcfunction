# API prologue. Run as the calling player (the owner). Args: {req:<int>, tool:"<name>"}.
# Writes a failing "internal" result first so an aborted call is never read as success.
# Sets: #api_owner (1 = caller owns a helper), #api_loaded (1 = that helper is loaded),
#       #api_job (helper_job, -1 if not loaded), #api_stay (1 = stay-at-base on).
# Tags the caller helper.cmd and the caller's helper(s) helper.api_me; internal/end clears both.
$data modify storage helper:api result set value {req:$(req),tool:"$(tool)",ok:0b,code:"internal",msg:"API call did not finish."}
function helper:id/assign
tag @a remove helper.cmd
tag @e[tag=helper.api_me] remove helper.api_me
tag @s add helper.cmd
scoreboard players set #api_owner helper_config 0
scoreboard players set #api_loaded helper_config 0
scoreboard players set #api_job helper_config -1
scoreboard players set #api_stay helper_config 0
execute if entity @s[tag=helper.owner] run scoreboard players set #api_owner helper_config 1
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.cmd,limit=1] helper_id run function helper:api/internal/read_helper
execute if score #api_loaded helper_config matches 1 run scoreboard players set #api_owner helper_config 1
