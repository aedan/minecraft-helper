# API: stay-at-base switch. As/at the owner. Args: {req, on:0|1}.
# on=1 cancels work; the helper returns to base and neither follows nor protects.
# Precedence is enforced in the datapack (combat/apply_mode), not only here.
$function helper:api/internal/begin {req:$(req),tool:"set_stay_at_base"}
$scoreboard players set #api_a1 helper_config $(on)
execute unless score #api_a1 helper_config matches 0..1 run return run function helper:api/internal/fail {code:"bad_args",msg:"on must be 0 or 1."}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute if score #api_a1 helper_config matches 1 unless score @s helper_bx = @s helper_bx run return run function helper:api/internal/fail {code:"no_base",msg:"No base is set. Call set_base first."}
execute if score #api_a1 helper_config matches 1 as @e[tag=helper.api_me] run function helper:api/internal/stay_on
execute if score #api_a1 helper_config matches 0 as @e[tag=helper.api_me] run scoreboard players set @s helper_stay 0
execute if score #api_a1 helper_config matches 1 run return run function helper:api/internal/ok {code:"stay_on",msg:"Staying at base. Not following or protecting."}
function helper:api/internal/ok {code:"stay_off",msg:"Stay-at-base is off. Protect-and-follow applies if it is on."}
