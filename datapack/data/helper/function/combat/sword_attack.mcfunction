execute if score @s helper_sword matches 1.. run return 0
execute unless entity @e[tag=helper.targeted,distance=..4,limit=1] run return 0

function helper:spawn/hold_melee
damage @e[tag=helper.targeted,limit=1] 7 minecraft:player_attack by @s
playsound minecraft:entity.player.attack.sweep master @a[distance=..16] ~ ~ ~ 0.9 1
particle minecraft:sweep_attack ^ ^1.2 ^1.2 0 0 0 0 1
scoreboard players set @s helper_sword 12
