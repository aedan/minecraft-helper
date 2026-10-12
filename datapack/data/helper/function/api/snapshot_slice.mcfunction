# API: capture the repeating tunnel segment behind the helper (relative to its facing)
# into storage helper:api pattern. As/at the owner. Args: {req, length:0..8}
# (0 = detect the period from 16 blocks behind; 1..8 = use this segment length).
# Read-only for the world. Result: length, facing (0 s 1 w 2 n 3 e), verified.
$function helper:api/internal/begin {req:$(req),tool:"snapshot_slice"}
$scoreboard players set #api_a1 helper_config $(length)
execute unless score #api_a1 helper_config matches 0..8 run return run function helper:api/internal/fail {code:"bad_args",msg:"length must be 0..8."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
scoreboard players operation #pat_req_len helper_config = #api_a1 helper_config
execute as @e[tag=helper.api_me,limit=1] at @s run function helper:pattern/snapshot
execute if score #pat_len helper_config matches 0 run return run function helper:api/internal/fail {code:"no_pattern",msg:"No repeating segment in the 16 blocks behind me. Face along the tunnel, or give the segment length."}
execute store result storage helper:api result.length int 1 run scoreboard players get #pat_len helper_config
execute store result storage helper:api result.facing int 1 run scoreboard players get #pat_dir helper_config
execute store result storage helper:api result.verified byte 1 run scoreboard players get #pat_verified helper_config
function helper:api/internal/ok {code:"captured",msg:"Pattern captured."}
