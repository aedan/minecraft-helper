# Netherite loadout (tier 3 / admin spawn). 26.3 enchantments are a flat id->level map.
item replace entity @s weapon.mainhand with minecraft:netherite_sword[minecraft:enchantments={"minecraft:sharpness":5,"minecraft:knockback":2,"minecraft:fire_aspect":2,"minecraft:unbreaking":3},minecraft:unbreakable={}]
item replace entity @s weapon.offhand with minecraft:shield[minecraft:unbreakable={}]
item replace entity @s armor.head with minecraft:netherite_helmet[minecraft:enchantments={"minecraft:protection":4,"minecraft:unbreaking":3},minecraft:unbreakable={}]
item replace entity @s armor.chest with minecraft:netherite_chestplate[minecraft:enchantments={"minecraft:protection":4,"minecraft:unbreaking":3},minecraft:unbreakable={}]
item replace entity @s armor.legs with minecraft:netherite_leggings[minecraft:enchantments={"minecraft:protection":4,"minecraft:unbreaking":3},minecraft:unbreakable={}]
item replace entity @s armor.feet with minecraft:netherite_boots[minecraft:enchantments={"minecraft:protection":4,"minecraft:unbreaking":3},minecraft:unbreakable={}]
attribute @s minecraft:max_health base set 40
attribute @s minecraft:knockback_resistance base set 0.4
data modify entity @s Health set value 40.0f
effect give @s minecraft:fire_resistance 4 0 true
