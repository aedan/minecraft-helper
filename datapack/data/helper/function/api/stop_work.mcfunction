# API: cancel current job and queue. Mode switches are unchanged. As the owner. Args: {req}.
$function helper:api/internal/begin {req:$(req),tool:"stop_work"}
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/fail {code:"not_loaded",msg:"Your helper is not loaded. Use set_protect_follow with come_now to recall it."}
execute as @e[tag=helper.api_me] run function helper:api/internal/cancel_work
function helper:api/internal/ok {code:"stopped",msg:"Work cancelled."}
