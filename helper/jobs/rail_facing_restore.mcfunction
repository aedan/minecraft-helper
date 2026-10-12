# Re-assert locked tunnel axis from helper_yaw (cardinal degrees). Prevents combat/idle from twisting rails.
execute if score @s helper_yaw matches 0 at @s run tp @s ~ ~ ~ 0 0
execute if score @s helper_yaw matches 90 at @s run tp @s ~ ~ ~ 90 0
execute if score @s helper_yaw matches 180 at @s run tp @s ~ ~ ~ 180 0
execute if score @s helper_yaw matches -180 at @s run tp @s ~ ~ ~ 180 0
execute if score @s helper_yaw matches -90 at @s run tp @s ~ ~ ~ -90 0
# Fallback if yaw never locked (legacy / mid-job reload): snap current look once
execute unless score @s helper_yaw = @s helper_yaw run function helper:jobs/rail_facing_snap
