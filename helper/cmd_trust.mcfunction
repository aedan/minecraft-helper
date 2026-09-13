# Command: /helper trust <player> - Mark a player as friend (trust_level=2)

# Set trust level to 2 for the target player
execute as @a[name=] run scoreboard players set @s trust_level 2
execute as @a[name=] run tag @s add helper.friend
execute as @a[name=] run tag @s remove helper.unknown_in_base
execute as @a[name=] run tag @s remove helper.foe

tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You are now trusted. ","color":"green"},{"text":"You can access base chests freely.","color":"gray"}]
playsound minecraft:entity.villager.yes master @s
