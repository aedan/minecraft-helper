# Mode: fetch resource
# Helper actively searches for the target resource

# Set fetch mode
scoreboard players set #mode helper_config 2

# Set fetch target (placeholder: diamond = 1)
scoreboard players set #fetch_target helper_config 1

tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Mode set to ","color":"green"},{"text":"Fetch Resource","color":"yellow"},{"text":". Helper will search for and mine diamonds.","color":"gray"}]
playsound minecraft:entity.villager.yes master @a[limit=1]
