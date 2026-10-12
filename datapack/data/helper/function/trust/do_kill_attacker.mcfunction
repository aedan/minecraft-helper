# do_kill_attacker: runs with @s = owner. Kills the attacker (@p non-friend near owner).
# Targets the attacker explicitly, never the owner.

# Mark the attacker as foe and kill it
execute at @s as @p[tag=!helper.friend,distance=..8,limit=1] run scoreboard players set @s trust_level 0
execute at @s as @p[tag=!helper.friend,distance=..8,limit=1] run tag @s add helper.foe
execute at @s as @p[tag=!helper.friend,distance=..8,limit=1] run kill @s

# Alert owner (the original @s)
tellraw @s [{"text":"[DEFENSE] ","color":"red","bold":true},{"text":"ATTACKER NEUTRALIZED. ","color":"dark_red"},{"text":"A player attacked you and was destroyed.","color":"gray"}]
playsound minecraft:entity.wither.death master @s
