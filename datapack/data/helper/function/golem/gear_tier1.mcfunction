scoreboard players set @a[tag=helper.summoner,limit=1] helper_tier 1
item replace entity @s weapon.mainhand with minecraft:wooden_sword[minecraft:enchantments={"minecraft:sharpness":1}]
item replace entity @s armor.head with minecraft:leather_helmet
item replace entity @s armor.chest with minecraft:leather_chestplate
item replace entity @s armor.legs with minecraft:leather_leggings
item replace entity @s armor.feet with minecraft:leather_boots
attribute @s minecraft:max_health base set 20
data modify entity @s Health set value 20.0f
data merge entity @s {CustomName:{text:"Helper"},CustomNameVisible:1b,hide_description:1b,description:{text:""}}
function helper:lifecycle/apply_bound_name
