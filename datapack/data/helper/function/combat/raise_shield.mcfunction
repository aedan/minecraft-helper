# Simulate a block: resistance while the shield is in the offhand.
execute unless entity @s[tag=helper.tier1] run item replace entity @s weapon.offhand with minecraft:shield[minecraft:unbreakable={}]
effect give @s minecraft:resistance 1 2 true
