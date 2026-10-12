# Apply bound display name from storage helper:bind {name:"tom"} onto @s (the helper).
# No-op if bind name missing. Safe to call on load/spawn/respawn/tick assert.
execute unless data storage helper:bind name run return 0
function helper:jobs/set_name with storage helper:bind
