# Args: {code:"<code>", msg:"<text>"}. As the caller. Final step of a failed API call.
$data modify storage helper:api result.code set value "$(code)"
$data modify storage helper:api result.msg set value "$(msg)"
data modify storage helper:api result.ok set value 0b
function helper:api/internal/end
