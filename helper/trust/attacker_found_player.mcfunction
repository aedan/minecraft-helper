# Attacker is a player: instant foe, destroy them

# Mark as foe
scoreboard players set @s trust_level 0
tag @s remove helper.friend
tag @s add helper.foe

# Kill them
kill @s

# Alert owner
tellraw @a[tag=helper.friend,limit=1] [{"text":"[DEFENSE] ","color":"red","bold":true},{"text":"ATTACKER NEUTRALIZED! ","color":"dark_red"},{"text":"A player attacked you. They have been destroyed.","color":"gray"}]
playsound minecraft:entity.wither.death master @a[tag=helper.friend,limit=1]
title @a[tag=helper.friend,limit=1] actionbar [{"text":"⚔ ATTACKER ELIMINATED","color":"red","bold":true}]
