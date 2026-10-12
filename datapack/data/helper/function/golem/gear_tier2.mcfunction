scoreboard players set @a[tag=helper.summoner,limit=1] helper_tier 2
item replace entity @s weapon.mainhand with minecraft:iron_sword[minecraft:enchantments={"minecraft:sharpness":2,"minecraft:knockback":1},minecraft:unbreakable={}]
item replace entity @s weapon.offhand with minecraft:shield[minecraft:unbreakable={}]
item replace entity @s armor.head with minecraft:iron_helmet[minecraft:enchantments={"minecraft:protection":2},minecraft:unbreakable={}]
item replace entity @s armor.chest with minecraft:iron_chestplate[minecraft:enchantments={"minecraft:protection":2},minecraft:unbreakable={}]
item replace entity @s armor.legs with minecraft:iron_leggings[minecraft:enchantments={"minecraft:protection":2},minecraft:unbreakable={}]
item replace entity @s armor.feet with minecraft:iron_boots[minecraft:enchantments={"minecraft:protection":2},minecraft:unbreakable={}]
attribute @s minecraft:max_health base set 30
attribute @s minecraft:knockback_resistance base set 0.2
data modify entity @s Health set value 30.0f
data merge entity @s {CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""}}
function helper:lifecycle/apply_bound_name
