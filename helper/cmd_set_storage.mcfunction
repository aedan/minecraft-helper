# Set storage area: mark current area as storage zone (16x16 blocks)

# Store storage area center
execute as @a[limit=1] store result score #storage_x helper_config run data get entity @s Pos[0]
execute as @a[limit=1] store result score #storage_y helper_config run data get entity @s Pos[1]
execute as @a[limit=1] store result score #storage_z helper_config run data get entity @s Pos[2]
scoreboard players set #storage_set helper_config 1

tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Storage area set! ","color":"green"},{"text":"16x16 block zone at current location.","color":"gray"}]
playsound minecraft:block.chest.open master @s
