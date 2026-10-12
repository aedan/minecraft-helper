# As a helper, every tick, before jobs run. Single source of truth for mode precedence:
#   stay_at_base (helper_stay=1)  >  protect_follow (helper_pf=1)  >  idle / legacy fetch
# Stay-at-base turns OFF following, the protect reflex, and fall recovery, whatever
# helper_pf says. helper_mode is derived from the two switches here, so no other code path
# (sidecar, triggers, chat commands) can make a staying helper follow.
# Sets #protect 1 only when the protect reflex may run this tick.

# First tick after upgrading: derive switches from the legacy helper_mode.
execute unless score @s helper_stay matches 0..1 if score @s helper_mode matches 1 run scoreboard players set @s helper_stay 1
execute unless score @s helper_stay matches 0..1 run scoreboard players set @s helper_stay 0
execute unless score @s helper_pf matches 0..1 if score @s helper_mode matches 2 run scoreboard players set @s helper_pf 0
execute unless score @s helper_pf matches 0..1 run scoreboard players set @s helper_pf 1

execute if score @s helper_stay matches 1 run scoreboard players set @s helper_mode 1
execute if score @s helper_stay matches 0 if score @s helper_pf matches 1 run scoreboard players set @s helper_mode 3
# protect_follow off: legacy fetch (2) stays fetch, anything else becomes idle (4).
execute if score @s helper_stay matches 0 if score @s helper_pf matches 0 unless score @s helper_mode matches 2 run scoreboard players set @s helper_mode 4

scoreboard players set #protect helper_config 0
execute if score @s helper_stay matches 0 if score @s helper_pf matches 1 run scoreboard players set #protect helper_config 1

# Staying at base: roaming jobs are not allowed (they could be queued by legacy triggers).
execute if score @s helper_stay matches 1 if score @s helper_job matches 5 run function helper:combat/stay_cancel_job
execute if score @s helper_stay matches 1 if score @s helper_job matches 7..8 run function helper:combat/stay_cancel_job
execute if score @s helper_stay matches 1 if score @s helper_job matches 11..15 run function helper:combat/stay_cancel_job
scoreboard players set @s[scores={helper_stay=1}] helper_fall 0
