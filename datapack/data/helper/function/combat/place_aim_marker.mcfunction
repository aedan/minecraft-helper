# Place/update the aim marker at the targeted hostile's position.
# Spawn if missing, then move it to the target.
execute unless entity @e[type=marker,tag=helper.aim,limit=1] run summon marker 0 255 0 {Tags:["helper.aim"],NoGravity:1b,PersistenceRequired:1b}
execute at @e[tag=helper.enemy,sort=nearest,limit=1] run tp @e[type=marker,tag=helper.aim,limit=1] ^ ^ ^
