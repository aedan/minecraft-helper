# API (owner command only): build a chest at base and store gathered items (job 6).
# Allowed while staying at base. Args: {req, replace:0|1}.
$function helper:api/internal/begin {req:$(req),tool:"store_items"}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
$scoreboard players set #api_replace helper_config $(replace)
execute unless score #api_replace helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"replace must be 0 or 1."}
execute if score #api_replace helper_config matches 0 if score #api_job helper_config matches 5..15 run return run function helper:api/internal/fail {code:"busy",msg:"Already working on a job. Call stop_work first or pass replace=true."}
scoreboard players set #job helper_config 6
scoreboard players set #gtype helper_config 0
function helper:api/internal/force_job
function helper:api/internal/expect {job:6,what:"storing items"}
