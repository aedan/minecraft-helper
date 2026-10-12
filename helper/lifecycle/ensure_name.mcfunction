# As helper: re-assert CustomName from helper:bind when missing or still default "Helper".
execute unless data storage helper:bind name run return 0
# Always re-merge visibility bits; set_name is cheap.
function helper:jobs/set_name with storage helper:bind
