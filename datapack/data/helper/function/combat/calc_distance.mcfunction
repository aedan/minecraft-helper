# Calculate distance between helper and threat

# Get helper position
execute as @e[tag=helper.active,limit=1] store result score #hx helper_combat run data get entity @s Pos[0]
execute as @e[tag=helper.active,limit=1] store result score #hy helper_combat run data get entity @s Pos[1]
execute as @e[tag=helper.active,limit=1] store result score #hz helper_combat run data get entity @s Pos[2]

# Get threat position
execute as @e[tag=helper.enemy,limit=1] store result score #tx helper_combat run data get entity @s Pos[0]
execute as @e[tag=helper.enemy,limit=1] store result score #ty helper_combat run data get entity @s Pos[1]
execute as @e[tag=helper.enemy,limit=1] store result score #tz helper_combat run data get entity @s Pos[2]

# Calculate X distance (simplified)
scoreboard players operation #dist helper_combat = #hx helper_combat
scoreboard players operation #dist helper_combat -= #tx helper_combat
