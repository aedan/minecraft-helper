# guard_position: teleport helper to a fixed offset beside the owner.
# Runs as the owner (@a[limit=1]). Uses absolute coords = owner pos + constant offset,
# so the helper stays at the same world spot relative to you no matter where you look.

# Store owner coords + offset into temp scores, then tp helper to that absolute position.
# Offset: 2 blocks east (+X), same Y.
execute store result score #gx helper_config run data get entity @s Pos[0]
execute store result score #gy helper_config run data get entity @s Pos[1]
execute store result score #gz helper_config run data get entity @s Pos[2]

# We can't tp directly to score values, so use a marker: place one at owner, offset it.
# Reuse a persistent guard marker positioned at owner, then tp helper 2 blocks from it.
execute unless entity @e[type=marker,tag=helper.guard,limit=1] run summon marker ^ ^ ^ {Tags:["helper.guard"],NoGravity:1b,PersistenceRequired:1b}
execute at @s run tp @e[type=marker,tag=helper.guard,limit=1] ^ ^ ^
execute at @e[type=marker,tag=helper.guard,limit=1] run tp @e[tag=helper.active,limit=1] ^2 ^ ^0
