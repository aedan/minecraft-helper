# As the caller (owner) with a base set.
data modify storage helper:api status.base set value {}
execute store result storage helper:api status.base.x int 1 run scoreboard players get @s helper_bx
execute store result storage helper:api status.base.y int 1 run scoreboard players get @s helper_by
execute store result storage helper:api status.base.z int 1 run scoreboard players get @s helper_bz
