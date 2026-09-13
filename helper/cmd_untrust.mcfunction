# Command: /helper untrust <player> - Remove friend status (trust_level=1)

execute as @a[name=] run scoreboard players set @s trust_level 1
execute as @a[name=] run tag @s remove helper.friend

tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Trust removed. ","color":"yellow"},{"text":"You are now an unknown. Do NOT open base chests.","color":"red"}]
playsound minecraft:entity.villager.no master @s
