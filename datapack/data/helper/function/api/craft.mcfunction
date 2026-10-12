# API: craft an item and deliver it to the owner (job 10). As the owner.
# Args: {req, item:"minecraft:<id>", count:1..64, replace:0|1}. The sidecar only sends
# ids from its fixed recipe list.
$function helper:api/internal/begin {req:$(req),tool:"craft"}
$scoreboard players set #api_a1 helper_config $(count)
execute unless score #api_a1 helper_config matches 1..64 run return run function helper:api/internal/fail {code:"bad_args",msg:"count must be 1..64."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute if score #api_stay helper_config matches 1 run return run function helper:api/internal/fail {code:"staying_at_base",msg:"Stay-at-base is on, so the helper will not leave base. Turn it off first."}
$scoreboard players set #api_replace helper_config $(replace)
execute unless score #api_replace helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"replace must be 0 or 1."}
execute if score #api_replace helper_config matches 0 if score #api_job helper_config matches 5..15 run return run function helper:api/internal/fail {code:"busy",msg:"Already working on a job. Call stop_work first or pass replace=true."}
$data modify storage helper:craft item set value "$(item)"
execute store result storage helper:craft count int 1 run scoreboard players get #api_a1 helper_config
scoreboard players set #job helper_config 10
scoreboard players set #gtype helper_config 0
function helper:api/internal/force_job
function helper:api/internal/expect {job:10,what:"crafting"}
