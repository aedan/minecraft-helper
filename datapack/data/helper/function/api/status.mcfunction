# API: status snapshot. As/at the owner. Args: {req}.
# Writes storage helper:api status:
#   {loaded, mode:"stay_at_base"|"protect_follow"|"idle", stay, protect_follow, protect,
#    defending, job_paused, job, queue:[q1,q2,q3], gtype, dig_left, on_horse,
#    helper:{x,y,z,health}, owner:{x,y,z,health,recalling}, base:{x,y,z}?, storage_set?}
$function helper:api/internal/begin {req:$(req),tool:"status"}
data modify storage helper:api status set value {loaded:0b,mode:"unknown",stay:0b,protect_follow:0b,protect:0b,defending:0b,job_paused:0b,job:0,queue:[0,0,0],owner:{},helper:{}}
execute store result storage helper:api status.owner.x int 1 run data get entity @s Pos[0]
execute store result storage helper:api status.owner.y int 1 run data get entity @s Pos[1]
execute store result storage helper:api status.owner.z int 1 run data get entity @s Pos[2]
execute store result storage helper:api status.owner.health int 1 run data get entity @s Health
execute store result storage helper:api status.owner.recalling int 1 run scoreboard players get @s helper_recall
execute if score @s helper_bx = @s helper_bx run function helper:api/internal/snap_base
execute if score #storage_set helper_config matches 1 run data modify storage helper:api status.storage_set set value 1b
execute as @e[tag=helper.api_me,limit=1] run function helper:api/internal/snap_helper
execute if score #api_owner helper_config matches 0 run return run function helper:api/internal/fail {code:"not_owner",msg:"You do not have a helper."}
execute if score #api_loaded helper_config matches 0 run return run function helper:api/internal/ok {code:"not_loaded",msg:"Helper is not loaded (far away, unloaded, or dead)."}
function helper:api/internal/ok {code:"ok",msg:"Status written to storage helper:api status."}
