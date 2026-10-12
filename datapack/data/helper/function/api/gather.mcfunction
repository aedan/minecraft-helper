# API: gather a resource (job 5). As/at the owner. Args: {req, resource:1..12, replace:0|1}.
# resource: 1 wood 2 coal 3 iron 4 copper 5 gold 6 redstone 7 lapis 8 diamond 9 emerald
#           10 quartz 11 ancient debris 12 food (hunt animals)
$function helper:api/internal/begin {req:$(req),tool:"gather"}
$scoreboard players set #api_a1 helper_config $(resource)
execute unless score #api_a1 helper_config matches 1..12 run return run function helper:api/internal/fail {code:"bad_args",msg:"resource must be 1..12."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute if score #api_stay helper_config matches 1 run return run function helper:api/internal/fail {code:"staying_at_base",msg:"Stay-at-base is on, so the helper will not leave base. Turn it off first."}
$scoreboard players set #api_replace helper_config $(replace)
execute unless score #api_replace helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"replace must be 0 or 1."}
execute if score #api_replace helper_config matches 0 if score #api_job helper_config matches 5..15 run return run function helper:api/internal/fail {code:"busy",msg:"Already working on a job. Call stop_work first or pass replace=true."}
scoreboard players set #job helper_config 5
scoreboard players operation #gtype helper_config = #api_a1 helper_config
function helper:api/internal/force_job
function helper:api/internal/expect {job:5,what:"gathering"}
