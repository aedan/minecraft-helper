# API: apply a sidecar-computed layout to the containers from api/organize_scan.
# As the owner. Args: {req, scan_req}. Expects storage helper:api org.plans: one list per
# scanned container (same order as org.chests) of {s:<slot>,f:<source container>,
# g:<source slot>,c:<count>}. Every item is copied from the scan snapshot, never invented.
# Atomic: the whole call runs inside one tick. It first checks that every container still
# exists and still holds exactly the snapshot; if anything changed (a player took items,
# a chest was broken), it writes nothing and fails with code "changed".
$function helper:api/internal/begin {req:$(req),tool:"organize_apply"}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
$execute unless data storage helper:api org{req:$(scan_req)} run return run function helper:api/internal/fail {code:"stale",msg:"No matching container scan. Scan again."}
execute if data storage helper:api org{scope:2} if score #api_stay helper_config matches 0 run return run function helper:api/internal/fail {code:"not_staying",msg:"Organizing the base only works in stay-at-base mode."}
execute store result score #org_n helper_config run data get storage helper:api org.chests
execute store result score #org_np helper_config run data get storage helper:api org.plans
execute unless score #org_n helper_config = #org_np helper_config run return run function helper:api/internal/fail {code:"bad_plan",msg:"Plan does not match the scanned containers. Nothing was moved."}
scoreboard players set #org_bad helper_config 0
scoreboard players set #org_i helper_config 0
# Positions are absolute; run in the helper's dimension (the owner may be elsewhere).
execute at @e[tag=helper.api_me,limit=1] run function helper:api/internal/org_verify_loop
execute if score #org_bad helper_config matches 1.. run data remove storage helper:api org
execute if score #org_bad helper_config matches 1.. run return run function helper:api/internal/fail {code:"changed",msg:"A container changed since the scan. Nothing was moved; scan again."}
data modify storage helper:api org.out set value []
scoreboard players set #org_i helper_config 0
function helper:api/internal/org_build_loop
execute if score #org_bad helper_config matches 1.. run data remove storage helper:api org
execute if score #org_bad helper_config matches 1.. run return run function helper:api/internal/fail {code:"bad_plan",msg:"Plan was invalid (bad slot, count, or source). Nothing was moved."}
scoreboard players set #org_i helper_config 0
execute at @e[tag=helper.api_me,limit=1] run function helper:api/internal/org_write_loop
execute store result storage helper:api result.chests_found int 1 run scoreboard players get #org_n helper_config
data remove storage helper:api org
function helper:api/internal/ok {code:"organized",msg:"Containers organized."}
