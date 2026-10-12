# API: protect-and-follow switch. As/at the owner. Args: {req, on:0|1, come_now:0|1}.
# Following is part of protecting. Stay-at-base overrides it (enforced every tick by
# combat/apply_mode), so with stay on the switch is saved but has no effect yet.
# come_now=1 (with on=1) interrupts work and warps the helper over, or starts a recall
# if the helper is not loaded.
$function helper:api/internal/begin {req:$(req),tool:"set_protect_follow"}
$scoreboard players set #api_a1 helper_config $(on)
execute unless score #api_a1 helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"on must be 0 or 1."}
$scoreboard players set #api_a2 helper_config $(come_now)
execute unless score #api_a2 helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"come_now must be 0 or 1."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_a2 helper_config matches 1 if score #api_a1 helper_config matches 0 run return run function helper:api/internal/fail {code:"bad_args",msg:"come_now needs on=1."}
execute if score #api_a2 helper_config matches 1 if score #api_stay helper_config matches 1 run return run function helper:api/internal/fail {code:"staying_at_base",msg:"Stay-at-base is on, so the helper will not come over. Turn it off first."}
execute if score #api_a2 helper_config matches 1 if score #api_loaded helper_config matches 0 at @s run return run function helper:api/internal/recall
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute as @e[tag=helper.api_me] run scoreboard players operation @s helper_pf = #api_a1 helper_config
execute if score #api_a2 helper_config matches 1 at @s run function helper:api/internal/come_now
execute if score #api_stay helper_config matches 1 run return run function helper:api/internal/ok {code:"saved_overridden",msg:"Saved, but stay-at-base is on and overrides it until turned off."}
execute if score #api_a1 helper_config matches 1 run return run function helper:api/internal/ok {code:"protect_follow_on",msg:"Protect-and-follow is on."}
function helper:api/internal/ok {code:"protect_follow_off",msg:"Protect-and-follow is off. The helper waits where it is."}
