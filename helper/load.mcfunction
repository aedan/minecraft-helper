# Helper data pack: load function
# Initializes scoreboards and config

# Create scoreboard objectives
scoreboard objectives add helper_config dummy
scoreboard objectives add helper_combat dummy
scoreboard objectives add trust_level dummy

# Set default mode (0 = no mode set)
scoreboard players set #mode helper_config 0

# Set default fetch target (0 = none)
scoreboard players set #fetch_target helper_config 0

# Initialize clocks
scoreboard players set #smelt_clock helper_config 0
scoreboard players set #horse_clock helper_config 0
scoreboard players set #golem_clock helper_config 0

# Enable trigger for helper commands
scoreboard objectives add helper_cmd trigger
execute as @a run scoreboard players enable @s helper_cmd

# Set owner as friend
execute as @a[limit=1] run scoreboard players set @s trust_level 2
execute as @a[limit=1] run tag @s add helper.friend

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"AI Helper v3 loaded. ","color":"green"},{"text":"Netherite protector with trust system, smelting, tree cutting, intelligent mining, and horse management.","color":"gray"}]
