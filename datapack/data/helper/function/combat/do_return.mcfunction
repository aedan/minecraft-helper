# Do the actual return: tp helper to base coords stored in scoreboard

# Temporarily set a marker at base then tp helper to it
# Simpler: use execute positioned with scoreboard-stored coords
execute in minecraft:overworld run tp @e[tag=helper.active,limit=1] ~ ~ ~

# Since we can't easily tp to scoreboard coords, use a marker entity
# Spawn a temporary marker at base, tp helper to it, kill marker
summon marker ~ ~ ~ {Tags:["helper.base_marker"],Lifetime:10}
tp @e[tag=helper.active,limit=1] @e[type=marker,tag=helper.base_marker,limit=1]
kill @e[type=marker,tag=helper.base_marker]

# Play return sound
execute as @e[tag=helper.active,limit=1] at @s run playsound minecraft:entity.enderman.teleport master @s
