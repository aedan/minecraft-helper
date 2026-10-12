execute if entity @s[tag=helper.tier1] run item replace entity @s weapon.mainhand with minecraft:bow
execute if entity @s[tag=helper.tier2] run item replace entity @s weapon.mainhand with minecraft:bow[minecraft:enchantments={"minecraft:power":2},minecraft:unbreakable={}]
execute if entity @s[tag=helper.tier3] run item replace entity @s weapon.mainhand with minecraft:bow[minecraft:enchantments={"minecraft:power":5,"minecraft:punch":2,"minecraft:flame":1,"minecraft:infinity":1,"minecraft:unbreaking":3},minecraft:unbreakable={}]
execute unless entity @s[tag=helper.tier1] unless entity @s[tag=helper.tier2] unless entity @s[tag=helper.tier3] run item replace entity @s weapon.mainhand with minecraft:bow
