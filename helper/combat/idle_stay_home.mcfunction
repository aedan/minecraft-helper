# Stay at base. Never fall back to following the owner.
# IMPORTANT: when standing on/near the base marker, do NOT face it + patrol (+6 yaw)
# — facing a marker at your feet makes yaw unstable and looks like continuous spinning.
function helper:jobs/my_base
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run function helper:jobs/mark_here_as_base
execute unless entity @e[type=marker,tag=helper.my_base,limit=1] run function helper:jobs/my_base

# Far from base: warp home
execute unless entity @e[type=marker,tag=helper.my_base,distance=..64,limit=1] run tp @s @e[type=marker,tag=helper.my_base,sort=nearest,limit=1]

# Mid-range: face nearest base and walk in (only when not on top of it)
execute if entity @e[type=marker,tag=helper.my_base,distance=3..64,limit=1] at @s facing entity @e[type=marker,tag=helper.my_base,sort=nearest,limit=1] feet run tp @s ~ ~ ~ ~ ~
execute if entity @e[type=marker,tag=helper.my_base,distance=10..64,limit=1] at @s run function helper:move/forward_fast
execute if entity @e[type=marker,tag=helper.my_base,distance=3..9.99,limit=1] at @s run function helper:move/forward

# At base (<=3): stand still — no patrol spin
# (intentionally empty beyond keeping rotation)

tag @e[type=marker,tag=helper.my_base] remove helper.my_base
