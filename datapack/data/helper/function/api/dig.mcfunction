# API: dig a straight 2-tall tunnel (job 8). As/at the owner.
# Args: {req, blocks:1..2000, keep:0|1, store:0|1, replace:0|1}. keep=1 continues the
# current corridor without warping to the owner; store=1 puts drops in a chest at the face.
$function helper:api/internal/begin {req:$(req),tool:"dig"}
$scoreboard players set #api_a1 helper_config $(blocks)
execute unless score #api_a1 helper_config matches 1..2000 run return run function helper:api/internal/fail {code:"bad_args",msg:"blocks must be 1..2000."}
$scoreboard players set #api_a2 helper_config $(keep)
execute unless score #api_a2 helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"keep must be 0 or 1."}
$scoreboard players set #api_a3 helper_config $(store)
execute unless score #api_a3 helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"store must be 0 or 1."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute if score #api_stay helper_config matches 1 run return run function helper:api/internal/fail {code:"staying_at_base",msg:"Stay-at-base is on, so the helper will not leave base. Turn it off first."}
$scoreboard players set #api_replace helper_config $(replace)
execute unless score #api_replace helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"replace must be 0 or 1."}
execute if score #api_replace helper_config matches 0 if score #api_job helper_config matches 5..15 run return run function helper:api/internal/fail {code:"busy",msg:"Already working on a job. Call stop_work first or pass replace=true."}
scoreboard players operation #dig helper_config = #api_a1 helper_config
scoreboard players operation #dig_keep helper_config = #api_a2 helper_config
scoreboard players operation #dig_store helper_config = #api_a3 helper_config
execute at @s run function helper:jobs/dig_start
tag @s add helper.cmd
function helper:api/internal/expect {job:8,what:"digging"}
