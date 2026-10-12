# Engage hostile: attack and destroy the nearest hostile mob

# Target nearest hostile within 24 blocks
execute if entity @e[tag=helper.enemy,distance=..24,sort=nearest,limit=1] run function helper:combat/engage_target

# Alert owner if hostile was found
execute if entity @e[tag=helper.enemy,distance=..24,sort=nearest,limit=1] run tellraw @a[tag=helper.friend,limit=1] [{"text":"[Security] ","color":"red"},{"text":"Hostile threat neutralized at base perimeter.","color":"yellow"}]
