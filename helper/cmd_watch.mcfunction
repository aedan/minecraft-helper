# Mode: watch back
# Helper follows owner closely, protects at all costs

scoreboard players set #mode helper_config 3
tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Mode set to ","color":"green"},{"text":"Watch Back","color":"yellow"},{"text":". Helper will follow you and protect you at all costs.","color":"gray"}]
playsound minecraft:entity.villager.yes master @a[limit=1]
