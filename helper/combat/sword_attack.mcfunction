# Sword attack: melee strike with knockback

# Turn helper to face target
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data modify entity @s Rotation set from entity @e[type=#minecraft:hostile,tag=helper.targeted,limit=1] Rotation

# Swing sword (visual effect)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run playsound minecraft:entity.villager.yes master @s

# Deal damage to target
execute as @e[type=villager,tag=helper.active,limit=1] at @s run damage @e[type=#minecraft:hostile,tag=helper.targeted,limit=1] 5 minecraft:player_attack @s

# Apply knockback
execute as @e[type=villager,tag=helper.active,limit=1] at @s run tp @e[type=#minecraft:hostile,tag=helper.targeted,limit=1] ^0 ^ ^-2
