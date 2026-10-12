scoreboard players operation @s helper_id = @e[tag=helper.self,limit=1] helper_id
item replace entity @s saddle with minecraft:saddle
item replace entity @s armor.body with minecraft:iron_horse_armor
attribute @s minecraft:max_health base set 30
attribute @s minecraft:movement_speed base set 0.3
data modify entity @s Health set value 30.0f
data merge entity @s {Tame:1b,Age:0,PersistenceRequired:1b,NoAI:1b}
