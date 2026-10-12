# As a helper in stay-at-base mode holding a roaming job: drop it.
function helper:api/internal/cancel_work
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"I'm staying at base, so I dropped that job. Turn stay-at-base off first.","color":"yellow"}]
