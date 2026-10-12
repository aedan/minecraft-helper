# kill_attacker_player: runs as the OWNER. Finds the nearest non-friend player within
# 8 blocks (the one who hit you) and destroys THAT player.
# NOTE: @p selects nearest OTHER player; combined with tag=!helper.friend it is the attacker.

execute at @s if entity @p[tag=!helper.friend,distance=..8,limit=1] run function helper:trust/do_kill_attacker
