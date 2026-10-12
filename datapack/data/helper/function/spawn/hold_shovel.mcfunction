execute if entity @s[tag=helper.tier1] run item replace entity @s weapon.mainhand with minecraft:iron_shovel[minecraft:unbreakable={}]
execute if entity @s[tag=helper.tier2] run item replace entity @s weapon.mainhand with minecraft:iron_shovel[minecraft:unbreakable={}]
execute if entity @s[tag=helper.tier3] run item replace entity @s weapon.mainhand with minecraft:netherite_shovel[minecraft:enchantments={"minecraft:efficiency":5},minecraft:unbreakable={}]
execute unless entity @s[tag=helper.tier1] unless entity @s[tag=helper.tier2] unless entity @s[tag=helper.tier3] run item replace entity @s weapon.mainhand with minecraft:iron_shovel[minecraft:unbreakable={}]
