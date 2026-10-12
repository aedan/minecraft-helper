# API: mark the owner's position as base. As/at the owner. Args: {req}.
$function helper:api/internal/begin {req:$(req),tool:"set_base"}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute at @s run function helper:combat/place_base_marker
tag @s add helper.cmd
function helper:api/internal/ok {code:"base_set",msg:"Base set here."}
