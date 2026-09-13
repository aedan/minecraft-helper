# Convert unknown to foe and destroy them

# Set trust level to 0 (foe)
scoreboard players set @s trust_level 0
tag @s remove helper.unknown_in_base
tag @s add helper.foe

# Kill the player
kill @s

# Alert owner
tellraw @a[tag=helper.friend,limit=1] [{"text":"[Security] ","color":"red"},{"text":"Intruder destroyed! ","color":"dark_red"},{"text":"Unknown player opened a chest in the base.","color":"gray"}]
playsound minecraft:entity.wither.death master @a[tag=helper.friend,limit=1]
