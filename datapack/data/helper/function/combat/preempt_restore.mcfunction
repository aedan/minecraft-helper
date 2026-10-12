# As a helper: the threat is gone, return to the saved work spot and resume the job.
tag @s remove helper.preempted
execute store result storage helper:tmp resume.x double 0.01 run scoreboard players get @s helper_wx
execute store result storage helper:tmp resume.y double 0.01 run scoreboard players get @s helper_wy
execute store result storage helper:tmp resume.z double 0.01 run scoreboard players get @s helper_wz
execute store result storage helper:tmp resume.yaw float 0.01 run scoreboard players get @s helper_wyaw
execute store result storage helper:tmp resume.pitch float 0.01 run scoreboard players get @s helper_wpitch
function helper:combat/resume_tp with storage helper:tmp resume
