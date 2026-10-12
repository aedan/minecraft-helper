# Mode: stay home
# Helper patrols around base, returns if strayed

scoreboard players set #mode helper_config 1
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Mode set to ","color":"green"},{"text":"Stay Home","color":"yellow"},{"text":". Helper will patrol base and return if strayed.","color":"gray"}]
playsound minecraft:entity.villager.yes master @a[limit=1]
