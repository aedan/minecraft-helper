# Tag real hostile mobs near the helper so we can select them by tag (no type-list needed).
# The #minecraft:hostile tag and comma type-lists are unreliable on this build,
# so we positively tag the known hostile types individually (single-type selectors always work).
# Runs as the helper. Tags any hostile within 24 blocks as helper.enemy, and clears the tag from the helper itself.

# Clear stale enemy tags beyond range (so dead/far mobs don't stay targeted)
execute as @e[tag=helper.active,limit=1] at @s run tag @e[tag=helper.enemy,distance=..40] remove helper.enemy

# Tag each hostile type within 24 blocks (single type= per selector - always valid)
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=zombie,distance=..24,tag=!helper.active,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=skeleton,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=husk,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=zombie_villager,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=drowned,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=creeper,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=spider,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=cave_spider,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=witch,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=enderman,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=blaze,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=wither_skeleton,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=pillager,distance=..24,limit=20] add helper.enemy
execute as @e[tag=helper.active,limit=1] at @s run tag @e[type=vindicator,distance=..24,limit=20] add helper.enemy
