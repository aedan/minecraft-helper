# Runs as the entity that last attacked the owner (may be a projectile).
execute if entity @s[type=arrow] on origin run function helper:trust/mark_living_attacker
execute if entity @s[type=spectral_arrow] on origin run function helper:trust/mark_living_attacker
execute if entity @s[type=trident] on origin run function helper:trust/mark_living_attacker
execute if entity @s[type=player] run function helper:trust/mark_living_attacker
execute if entity @s[type=#helper:hostiles] run function helper:trust/mark_living_attacker
