# Travel mount for long hunt journeys.
# Lifecycle: if already riding → noop; if our helper_id horse exists → remount/reuse; else spawn once.
# Never kills a mount here.

execute if score @s helper_on_horse matches 1 run return 0

# Resolve horse bound to this helper
tag @e[type=horse,tag=helper.my_horse] remove helper.my_horse
execute as @e[type=horse,tag=helper.horse] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_horse

# Reuse existing horse: pull nearby if needed, then mount
execute if entity @e[type=horse,tag=helper.my_horse,limit=1] unless entity @e[type=horse,tag=helper.my_horse,distance=..8,limit=1] at @s run tp @e[type=horse,tag=helper.my_horse,limit=1] ^1.2 ^ ^
execute if entity @e[type=horse,tag=helper.my_horse,limit=1] run ride @s mount @e[type=horse,tag=helper.my_horse,sort=nearest,limit=1]
execute if entity @e[type=horse,tag=helper.my_horse,limit=1] run scoreboard players set @s helper_on_horse 1
tag @e[type=horse,tag=helper.my_horse] remove helper.my_horse
execute if score @s helper_on_horse matches 1 run return 0

# No bound horse exists — spawn exactly one and ride
function helper:horse/spawn_and_ride
