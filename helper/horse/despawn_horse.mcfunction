# Despawn horse: remove it when owner gets off

kill @e[type=horse,tag=helper.horse]

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Horse despawned. ","color":"yellow"},{"text":"No longer needed.","color":"gray"}]
playsound minecraft:entity.horse.armor master @a[limit=1]
