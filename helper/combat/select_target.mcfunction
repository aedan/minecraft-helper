# Prefer: who just hurt the owner, then hostiles. Players ONLY if designated hunt_target
# or priority_target (owner just attacked). No opportunistic PvP on random foe players.

execute if entity @e[tag=helper.priority_target,tag=!helper.los_skip,distance=..32,limit=1] run tag @e[tag=helper.priority_target,tag=!helper.los_skip,distance=..32,sort=nearest,limit=1] add helper.targeted

# Designated hunt target (owner kill order)
execute unless entity @e[tag=helper.targeted,limit=1] if entity @a[tag=helper.hunt_target,tag=!helper.los_skip,distance=..48,limit=1] run tag @a[tag=helper.hunt_target,tag=!helper.los_skip,distance=..48,limit=1] add helper.targeted

# Hostiles near owner
execute unless entity @e[tag=helper.targeted,limit=1] as @a[tag=helper.my_owner,limit=1] at @s if entity @e[type=#helper:hostiles,tag=!helper.active,tag=!helper.horse,tag=!helper.los_skip,distance=..16,limit=1] run tag @e[type=#helper:hostiles,tag=!helper.active,tag=!helper.horse,tag=!helper.los_skip,distance=..16,sort=nearest,limit=1] add helper.targeted

# Hostiles near helper — never auto-pick foe players here
execute unless entity @e[tag=helper.targeted,limit=1] at @s run tag @e[type=#helper:hostiles,tag=!helper.active,tag=!helper.horse,tag=!helper.los_skip,distance=..24,sort=nearest,limit=1] add helper.targeted
