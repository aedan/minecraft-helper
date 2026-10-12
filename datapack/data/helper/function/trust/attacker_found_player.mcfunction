# Attacker is another player: mark as foe and destroy the ATTACKER (not the owner).
# The attacker is the nearest non-friend player within 8 blocks of the owner.

execute as @a[limit=1] at @s run function helper:trust/kill_attacker_player
