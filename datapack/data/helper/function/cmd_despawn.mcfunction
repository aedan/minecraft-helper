function helper:id/assign
scoreboard players set @s helper_want 0
scoreboard players set @s helper_recall 0
scoreboard players set @s helper_missing 0
scoreboard players set @s helper_respawn_cd 0
function helper:util/kill_mine
# Unforceload base chunk we were holding
execute if score @s helper_bfx = @s helper_bfx store result storage helper:chunk x int 1 run scoreboard players get @s helper_bfx
execute if score @s helper_bfx = @s helper_bfx store result storage helper:chunk z int 1 run scoreboard players get @s helper_bfz
execute if score @s helper_bfx = @s helper_bfx run function helper:chunk/unforce_at with storage helper:chunk
scoreboard players reset @s helper_bfx
scoreboard players reset @s helper_bfz
scoreboard players reset @s helper_bx
scoreboard players reset @s helper_by
scoreboard players reset @s helper_bz
scoreboard players reset @s helper_hx
scoreboard players reset @s helper_hy
scoreboard players reset @s helper_hz
tag @s remove helper.owner
team leave @s
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Helper despawned.","color":"red"}]
playsound minecraft:entity.villager.no master @s ~ ~ ~ 1 1
