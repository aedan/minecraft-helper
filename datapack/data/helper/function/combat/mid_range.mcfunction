# Close the gap while strafing; shoot if the bow is ready.

function helper:combat/strafe
execute if score @s helper_bow matches 0 if entity @e[tag=helper.targeted,distance=5..] run function helper:combat/bow_attack
execute if score @s helper_sword matches 0 if entity @e[tag=helper.targeted,distance=..4] run function helper:combat/sword_attack
