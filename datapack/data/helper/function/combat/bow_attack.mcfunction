execute if score @s helper_bow matches 1.. run return 0
execute unless entity @e[tag=helper.targeted,limit=1] run return 0

# Never shoot without clear line of sight to the mob
function helper:combat/los_check
execute unless score #los helper_config matches 1 run return 0

function helper:spawn/hold_bow
# Face the combat target so the shot (and Tom) look aimed at the foe
execute at @s facing entity @e[tag=helper.targeted,limit=1] eyes run tp @s ~ ~ ~ ~ ~
playsound minecraft:entity.skeleton.shoot master @a[distance=..24] ~ ~ ~ 1 1.1
function helper:combat/fire_arrow
scoreboard players set @s helper_bow 22
