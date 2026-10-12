# API (owner command only, not a model tool): hunt a named online player (job 11).
# As the owner. Args: {req, target:"<player name>"} — the sidecar validates the name.
$function helper:api/internal/begin {req:$(req),tool:"hunt"}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute if score #api_stay helper_config matches 1 run return run function helper:api/internal/fail {code:"staying_at_base",msg:"Stay-at-base is on, so the helper will not leave base. Turn it off first."}
$execute unless entity @a[name=$(target),limit=1] run return run function helper:api/internal/fail {code:"offline",msg:"That player is not online."}
$execute if entity @s[name=$(target)] run return run function helper:api/internal/fail {code:"bad_args",msg:"I will not hunt you."}
tag @a remove helper.hunt_victim
$tag @a[name=$(target),limit=1] add helper.hunt_victim
function helper:jobs/hunt_start
tag @s add helper.cmd
function helper:api/internal/expect {job:11,what:"the hunt"}
