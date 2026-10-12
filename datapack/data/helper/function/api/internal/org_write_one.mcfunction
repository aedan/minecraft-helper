# Args: {i}
$data modify storage helper:api org.cur.c set from storage helper:api org.chests[$(i)]
$data modify storage helper:api org.cur.c.new set from storage helper:api org.out[$(i)]
function helper:api/internal/org_write_at with storage helper:api org.cur.c
