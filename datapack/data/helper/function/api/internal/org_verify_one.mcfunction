# Args: {i}
$data modify storage helper:api org.cur.c set from storage helper:api org.chests[$(i)]
function helper:api/internal/org_verify_at with storage helper:api org.cur.c
