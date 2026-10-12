# Set base: mark current player location as the base

# Store player position as base
execute as @a[limit=1] run scoreboard players set #base_x helper_config < #x
execute as @a[limit=1] run scoreboard players set #base_y helper_config < #y
execute as @a[limit=1] run scoreboard players set #base_z helper_config < #z

tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Base set to current location. ","color":"green"},{"text":"Helper will return here in Stay Home mode.","color":"gray"}]
playsound minecraft:block.beacon.activate master @a[limit=1]
