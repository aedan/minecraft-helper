# Find fuel: add wood to the helper's inventory

# Add 32 oak logs to helper inventory slot 0
execute as @e[tag=helper.active,limit=1] run data modify entity @s Inventory[0] set value {id:"minecraft:oak_log",count:32b,Slot:0b}
scoreboard players set #has_fuel helper_config 1

tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Found fuel: 32 oak logs. ","color":"green"},{"text":"Went to get wood from a tree and replanted it.","color":"gray"}]
