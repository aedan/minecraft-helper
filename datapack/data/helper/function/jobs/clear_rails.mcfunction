# Job 14: seek past good continuous dual rails, then strip messed rails+center torches.
# helper_gtype 0=seeking 1=clearing. helper_no_tree=cleared count.
# Mess signature (every-other): dual + gap ahead + dual at +2 → clear.
# Good tip: dual + gap ahead + no dual at +2 → keep tip, clear from next cell.
# Resume protect: 12 continuous dual ahead while clearing → finish.

execute unless score @s helper_dig_left matches 1.. run function helper:jobs/clear_rails_finish
execute unless score @s helper_dig_left matches 1.. run return 0

function helper:jobs/rail_facing_restore

scoreboard players set #rail_has_l helper_config 0
scoreboard players set #rail_has_r helper_config 0
scoreboard players set #rail_dual helper_config 0
execute at @s if block ^-1 ^ ^ #minecraft:rails run scoreboard players set #rail_has_l helper_config 1
execute at @s if block ^-1 ^-1 ^ #minecraft:rails run scoreboard players set #rail_has_l helper_config 1
execute at @s if block ^1 ^ ^ #minecraft:rails run scoreboard players set #rail_has_r helper_config 1
execute at @s if block ^1 ^-1 ^ #minecraft:rails run scoreboard players set #rail_has_r helper_config 1
execute if score #rail_has_l helper_config matches 1 if score #rail_has_r helper_config matches 1 run scoreboard players set #rail_dual helper_config 1

scoreboard players set #rail_fwd_dual helper_config 0
scoreboard players set #rail_fwd2_dual helper_config 0
execute at @s if block ^-1 ^ ^1 #minecraft:rails if block ^1 ^ ^1 #minecraft:rails run scoreboard players set #rail_fwd_dual helper_config 1
execute at @s if block ^-1 ^ ^2 #minecraft:rails if block ^1 ^ ^2 #minecraft:rails run scoreboard players set #rail_fwd2_dual helper_config 1

scoreboard players set #rail_look_good helper_config 0
execute at @s if block ^-1 ^ ^1 #minecraft:rails if block ^1 ^ ^1 #minecraft:rails if block ^-1 ^ ^2 #minecraft:rails if block ^1 ^ ^2 #minecraft:rails if block ^-1 ^ ^3 #minecraft:rails if block ^1 ^ ^3 #minecraft:rails if block ^-1 ^ ^4 #minecraft:rails if block ^1 ^ ^4 #minecraft:rails if block ^-1 ^ ^5 #minecraft:rails if block ^1 ^ ^5 #minecraft:rails if block ^-1 ^ ^6 #minecraft:rails if block ^1 ^ ^6 #minecraft:rails if block ^-1 ^ ^7 #minecraft:rails if block ^1 ^ ^7 #minecraft:rails if block ^-1 ^ ^8 #minecraft:rails if block ^1 ^ ^8 #minecraft:rails if block ^-1 ^ ^9 #minecraft:rails if block ^1 ^ ^9 #minecraft:rails if block ^-1 ^ ^10 #minecraft:rails if block ^1 ^ ^10 #minecraft:rails if block ^-1 ^ ^11 #minecraft:rails if block ^1 ^ ^11 #minecraft:rails if block ^-1 ^ ^12 #minecraft:rails if block ^1 ^ ^12 #minecraft:rails run scoreboard players set #rail_look_good helper_config 1

# Staging: #rail_do_clear 0/1, #rail_enter_clear 0/1
scoreboard players set #rail_do_clear helper_config 0
scoreboard players set #rail_enter_clear helper_config 0

# --- SEEKING branch (helper_gtype 0) ---
# continuous good: dual + fwd dual → stay seeking, no clear
execute if score @s helper_gtype matches 0 if score #rail_dual helper_config matches 1 if score #rail_fwd_dual helper_config matches 1 run scoreboard players set #rail_enter_clear helper_config 0
# mess every-other underfoot: dual + !fwd + fwd2 → clear now
execute if score @s helper_gtype matches 0 if score #rail_dual helper_config matches 1 if score #rail_fwd_dual helper_config matches 0 if score #rail_fwd2_dual helper_config matches 1 run scoreboard players set #rail_enter_clear helper_config 1
execute if score @s helper_gtype matches 0 if score #rail_dual helper_config matches 1 if score #rail_fwd_dual helper_config matches 0 if score #rail_fwd2_dual helper_config matches 1 run scoreboard players set #rail_do_clear helper_config 1
# good tip: dual + !fwd + !fwd2 → enter clear mode but keep this tip cell
execute if score @s helper_gtype matches 0 if score #rail_dual helper_config matches 1 if score #rail_fwd_dual helper_config matches 0 if score #rail_fwd2_dual helper_config matches 0 run scoreboard players set #rail_enter_clear helper_config 1
execute if score @s helper_gtype matches 0 if score #rail_dual helper_config matches 1 if score #rail_fwd_dual helper_config matches 0 if score #rail_fwd2_dual helper_config matches 0 run scoreboard players set #rail_do_clear helper_config 0
# gap underfoot → clear
execute if score @s helper_gtype matches 0 if score #rail_dual helper_config matches 0 run scoreboard players set #rail_enter_clear helper_config 1
execute if score @s helper_gtype matches 0 if score #rail_dual helper_config matches 0 run scoreboard players set #rail_do_clear helper_config 1

execute if score @s helper_gtype matches 0 if score #rail_enter_clear helper_config matches 1 run scoreboard players set @s helper_gtype 1

# --- CLEARING branch ---
execute if score @s helper_gtype matches 1 if score #rail_look_good helper_config matches 1 run function helper:jobs/clear_rails_finish
execute if score @s helper_gtype matches 1 if score #rail_look_good helper_config matches 1 run return 0
# Default while clearing: clear unless seeking tip exception left do_clear 0 this tick
execute if score @s helper_gtype matches 1 if score #rail_enter_clear helper_config matches 0 run scoreboard players set #rail_do_clear helper_config 1
# If we just entered from good tip (enter_clear=1 and do_clear still 0): keep 0
# If we just entered from mess/gap (do_clear already 1): keep 1
# Subsequent clearing ticks: enter_clear=0 so do_clear forced 1 above

execute if score #rail_do_clear helper_config matches 1 run function helper:jobs/clear_rails_scan

scoreboard players set #rail_step helper_config 0
execute at @s if block ^ ^ ^1 #helper:passable run scoreboard players set #rail_step helper_config 1
execute at @s if block ^ ^ ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 1
execute at @s if block ^ ^ ^1 minecraft:redstone_torch run scoreboard players set #rail_step helper_config 1
execute at @s if score #rail_step helper_config matches 0 if block ^ ^-1 ^1 #helper:passable run scoreboard players set #rail_step helper_config 2
execute at @s if score #rail_step helper_config matches 0 if block ^ ^-1 ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 2
execute at @s if score #rail_step helper_config matches 0 if block ^ ^1 ^1 #helper:passable run scoreboard players set #rail_step helper_config 3
execute at @s if score #rail_step helper_config matches 0 if block ^ ^1 ^1 #minecraft:rails run scoreboard players set #rail_step helper_config 3

execute if score #rail_step helper_config matches 1 at @s run tp @s ^ ^ ^1
execute if score #rail_step helper_config matches 2 at @s run tp @s ^ ^-1 ^1
execute if score #rail_step helper_config matches 3 at @s run tp @s ^ ^1 ^1
execute if score #rail_step helper_config matches 1..3 at @s align xz positioned ~0.5 ~ ~0.5 run tp @s ~ ~ ~ ~ ~

execute if score #rail_step helper_config matches 1..3 run scoreboard players remove @s helper_dig_left 1
execute if score #rail_step helper_config matches 1..3 run scoreboard players set @s helper_work_cd 0

execute if score #rail_step helper_config matches 0 run scoreboard players add @s helper_work_cd 1
execute if score #rail_step helper_config matches 0 if score @s helper_work_cd matches 5.. run function helper:jobs/clear_rails_finish
