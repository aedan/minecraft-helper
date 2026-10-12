# API: rail work along the owner's look direction. As/at the owner.
# Args: {req, action:1..4, blocks:1..10000, rail_type:0..4, replace:0|1}
# action: 1 lay (job 12) 2 repair (job 15) 3 clear_bad (job 14) 4 clear_torches (job 13)
# rail_type (lay only): 0 auto (learn pattern) 1 rail 2 powered 3 detector 4 activator
# blocks: max length; 10000 means "until the tunnel ends".
$function helper:api/internal/begin {req:$(req),tool:"rails"}
$scoreboard players set #api_a1 helper_config $(action)
execute unless score #api_a1 helper_config matches 1..4 run return run function helper:api/internal/fail {code:"bad_args",msg:"action must be 1..4."}
$scoreboard players set #api_a2 helper_config $(blocks)
execute unless score #api_a2 helper_config matches 1..10000 run return run function helper:api/internal/fail {code:"bad_args",msg:"blocks must be 1..10000."}
$scoreboard players set #api_a3 helper_config $(rail_type)
execute unless score #api_a3 helper_config matches 0..4 run return run function helper:api/internal/fail {code:"bad_args",msg:"rail_type must be 0..4."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute if score #api_stay helper_config matches 1 run return run function helper:api/internal/fail {code:"staying_at_base",msg:"Stay-at-base is on, so the helper will not leave base. Turn it off first."}
$scoreboard players set #api_replace helper_config $(replace)
execute unless score #api_replace helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"replace must be 0 or 1."}
execute if score #api_replace helper_config matches 0 if score #api_job helper_config matches 5..15 run return run function helper:api/internal/fail {code:"busy",msg:"Already working on a job. Call stop_work first or pass replace=true."}
scoreboard players operation #dig helper_config = #api_a2 helper_config
scoreboard players set #brain_rail helper_config 0
execute if score #api_a3 helper_config matches 1..4 run scoreboard players operation #brain_rail helper_config = #api_a3 helper_config
execute if score #api_a3 helper_config matches 1..4 run scoreboard players add #brain_rail helper_config 9
execute if score #api_a1 helper_config matches 1 at @s run function helper:jobs/rail_start
execute if score #api_a1 helper_config matches 2 at @s run function helper:jobs/repair_rails_start
execute if score #api_a1 helper_config matches 3 at @s run function helper:jobs/clear_rails_start
execute if score #api_a1 helper_config matches 4 at @s run function helper:jobs/clear_wall_torches_start
tag @s add helper.cmd
execute if score #api_a1 helper_config matches 1 run return run function helper:api/internal/expect {job:12,what:"laying rails"}
execute if score #api_a1 helper_config matches 2 run return run function helper:api/internal/expect {job:15,what:"repairing rails"}
execute if score #api_a1 helper_config matches 3 run return run function helper:api/internal/expect {job:14,what:"clearing bad rails"}
function helper:api/internal/expect {job:13,what:"clearing wall torches"}
