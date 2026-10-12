# Sidestep and raise shield when a projectile is incoming.
execute if entity @e[type=arrow,tag=!helper.arrow,distance=..8,limit=1] run function helper:combat/raise_shield
execute if entity @e[type=spectral_arrow,tag=!helper.arrow,distance=..8,limit=1] run function helper:combat/raise_shield
execute if entity @e[type=trident,distance=..8,limit=1] run function helper:combat/raise_shield
execute if entity @e[type=small_fireball,distance=..10,limit=1] run function helper:combat/raise_shield
execute if entity @e[type=fireball,distance=..12,limit=1] run function helper:combat/raise_shield

execute if score @s helper_dodge matches 1.. run return 0
execute if entity @e[type=arrow,tag=!helper.arrow,distance=..6,limit=1] run function helper:combat/do_dodge
execute if entity @e[type=spectral_arrow,tag=!helper.arrow,distance=..6,limit=1] run function helper:combat/do_dodge
execute if entity @e[type=trident,distance=..6,limit=1] run function helper:combat/do_dodge
execute if entity @e[type=small_fireball,distance=..8,limit=1] run function helper:combat/do_dodge
