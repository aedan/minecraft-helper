# API: find chests/barrels to organize and snapshot their contents. As/at the owner.
# Args: {req, scope:1|2}. 1 = "ahead": up to 8 containers in front of the helper
# (3 deep, 5 wide, 4 high). 2 = "base": up to 24 containers within 6 blocks of the
# storage point (cmd_set_storage) or the base; only allowed in stay-at-base mode with no job.
# Output: storage helper:api org {req, scope, chests:[{x,y,z,half,facing,items:[...]}]}
#         result.chests_found. Loot-table chests are skipped. Nothing in the world changes.
# The sidecar plans the new layout and calls api/organize_apply.
$function helper:api/internal/begin {req:$(req),tool:"organize_scan"}
$scoreboard players set #api_a1 helper_config $(scope)
execute unless score #api_a1 helper_config matches 1..2 run return run function helper:api/internal/fail {code:"bad_args",msg:"scope must be 1 (ahead) or 2 (base)."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute if score #api_a1 helper_config matches 2 if score #api_stay helper_config matches 0 run return run function helper:api/internal/fail {code:"not_staying",msg:"Organizing the base only works in stay-at-base mode."}
execute unless score #api_job helper_config matches 0..4 run return run function helper:api/internal/fail {code:"busy",msg:"The helper is working on a job. Call stop_work first."}
execute if score #api_a1 helper_config matches 2 unless score #storage_set helper_config matches 1 unless score @s helper_bx = @s helper_bx run return run function helper:api/internal/fail {code:"no_base",msg:"No base or storage point is set."}
$data modify storage helper:api org set value {req:$(req),chests:[]}
execute store result storage helper:api org.scope int 1 run scoreboard players get #api_a1 helper_config
scoreboard players set #org_n helper_config 0
execute if score #api_a1 helper_config matches 1 run scoreboard players set #org_max helper_config 8
execute if score #api_a1 helper_config matches 2 run scoreboard players set #org_max helper_config 24
execute if score #api_a1 helper_config matches 1 as @e[tag=helper.api_me,limit=1] at @s run function helper:api/internal/org_scan_ahead
execute if score #api_a1 helper_config matches 2 at @e[tag=helper.api_me,limit=1] run function helper:api/internal/org_scan_base
execute store result storage helper:api result.chests_found int 1 run scoreboard players get #org_n helper_config
execute if score #org_n helper_config matches 0 run return run function helper:api/internal/ok {code:"no_chests",msg:"No chests or barrels found in range."}
function helper:api/internal/ok {code:"scanned",msg:"Containers snapshotted."}
