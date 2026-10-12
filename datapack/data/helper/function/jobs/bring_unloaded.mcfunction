# Helper not in loaded chunks. Kick off per-player forceload recall using stored coords.
# Immediate entity checks after forceload always fail (chunk load is deferred) — do not
# claim failure in this same tick; lifecycle/owner_tick finishes the job.
function helper:lifecycle/start_recover
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Loading helper chunk…","color":"gray"}]
