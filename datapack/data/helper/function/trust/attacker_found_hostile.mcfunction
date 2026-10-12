# Attacker is a hostile mob: engage and destroy it

# Target the hostile
execute as @e[tag=helper.active,limit=1] at @s run function helper:combat/engage_target

# Alert owner
tellraw @a[tag=helper.friend,limit=1] [{"text":"[DEFENSE] ","color":"red","bold":true},{"text":"THREAT ENGAGED! ","color":"dark_red"},{"text":"A hostile attacked you. Destroying it now.","color":"gray"}]
playsound minecraft:entity.wither.spawn master @a[tag=helper.friend,limit=1]
