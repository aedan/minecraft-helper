# API: smelt at base (job 9). Allowed while staying at base. As the owner.
# Args: {req, material:2|3|4|5|11, replace:0|1} — 2 coal 3 iron 4 copper 5 gold 11 debris.
$function helper:api/internal/begin {req:$(req),tool:"smelt"}
$scoreboard players set #api_a1 helper_config $(material)
execute unless score #api_a1 helper_config matches 2..5 unless score #api_a1 helper_config matches 11 run return run function helper:api/internal/fail {code:"bad_args",msg:"material must be 2, 3, 4, 5 or 11."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
$scoreboard players set #api_replace helper_config $(replace)
execute unless score #api_replace helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"replace must be 0 or 1."}
execute if score #api_replace helper_config matches 0 if score #api_job helper_config matches 5..15 run return run function helper:api/internal/fail {code:"busy",msg:"Already working on a job. Call stop_work first or pass replace=true."}
execute unless score @s helper_bx = @s helper_bx run return run function helper:api/internal/fail {code:"no_base",msg:"No base is set. Call set_base first."}
scoreboard players set #job helper_config 9
scoreboard players operation #gtype helper_config = #api_a1 helper_config
function helper:api/internal/force_job
function helper:api/internal/expect {job:9,what:"smelting"}
