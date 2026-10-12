# Args: {code:"<code>", msg:"<text>"}. As the caller. Final step of a successful API call.
$data modify storage helper:api result.code set value "$(code)"
$data modify storage helper:api result.msg set value "$(msg)"
data modify storage helper:api result.ok set value 1b
execute as @e[tag=helper.api_me,limit=1] store result storage helper:api result.job int 1 run scoreboard players get @s helper_job
function helper:api/internal/end
