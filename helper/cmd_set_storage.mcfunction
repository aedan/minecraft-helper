# Command: /helper set_storage - Mark current area as storage zone (16x16 blocks)

# Store storage area center
execute as @a[limit=1] run scoreboard players set #storage_x helper_config < #x
execute as @a[limit=1] run scoreboard players set #storage_y helper_config < #y
execute as @a[limit=1] run scoreboard players set #storage_z helper_config < #z
scoreboard players set #storage_set helper_config 1

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Storage area set! ","color":"green"},{"text":"16x16 block zone at current location. Helper will organize chests here.","color":"gray"}]
playsound minecraft:block.chest.open master @a[limit=1]
