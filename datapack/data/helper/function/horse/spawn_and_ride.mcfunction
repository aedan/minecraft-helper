execute at @s run summon horse ^1.2 ^ ^ {Tame:1b,PersistenceRequired:1b,NoAI:1b,Tags:["helper.horse","helper.horse_new"]}
execute as @e[type=horse,tag=helper.horse_new,limit=1] run function helper:horse/setup
ride @s mount @e[type=horse,tag=helper.horse_new,limit=1]
tag @e[type=horse,tag=helper.horse_new] remove helper.horse_new
scoreboard players set @s helper_on_horse 1
scoreboard players set #has_horse helper_config 1
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Mounted up.","color":"green"}]
playsound minecraft:entity.horse.saddle master @a[tag=helper.my_owner,limit=1] ~ ~ ~ 1 1
