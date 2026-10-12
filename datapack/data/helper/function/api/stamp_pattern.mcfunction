# API: repeat the captured pattern forward from the helper. As/at the owner.
# Args: {req, blocks:1..64}. Result: placed, removed, stopped_at (first slice not
# stamped, 0 = all done), reason (done | obstructed | unloaded), rotated.
$function helper:api/internal/begin {req:$(req),tool:"stamp_pattern"}
$scoreboard players set #api_a1 helper_config $(blocks)
execute unless score #api_a1 helper_config matches 1..64 run return run function helper:api/internal/fail {code:"bad_args",msg:"blocks must be 1..64."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute if score #api_stay helper_config matches 1 run return run function helper:api/internal/fail {code:"staying_at_base",msg:"Stay-at-base is on, so the helper will not leave base. Turn it off first."}
execute unless score #api_job helper_config matches 0..4 run return run function helper:api/internal/fail {code:"busy",msg:"The helper is working on a job. Call stop_work first."}
execute unless data storage helper:api pattern.cells[0] run return run function helper:api/internal/fail {code:"no_pattern",msg:"No pattern captured yet. Use snapshot_slice first."}
execute unless data storage helper:api {pattern:{width:5,height:4}} run return run function helper:api/internal/fail {code:"no_pattern",msg:"The stored pattern has an old format. Capture it again."}
scoreboard players operation #pat_n helper_config = #api_a1 helper_config
execute as @e[tag=helper.api_me,limit=1] at @s run function helper:pattern/stamp
execute store result storage helper:api result.placed int 1 run scoreboard players get #pat_placed helper_config
execute store result storage helper:api result.removed int 1 run scoreboard players get #pat_removed helper_config
execute store result storage helper:api result.stopped_at int 1 run scoreboard players get #pat_at helper_config
execute store result storage helper:api result.rotated byte 1 run scoreboard players get #pat_rot helper_config
data modify storage helper:api result.reason set from storage helper:tmp stamp.reason
execute if score #pat_stop helper_config matches ..0 run return run function helper:api/internal/fail with storage helper:tmp stamp
execute if score #pat_at helper_config matches 1.. run return run function helper:api/internal/ok {code:"partial",msg:"Stamped part of the way; see stopped_at and reason."}
function helper:api/internal/ok {code:"stamped",msg:"Pattern stamped."}
