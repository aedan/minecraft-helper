# Helper data pack: main tick function
# Runs every tick to update AI behavior, trust, smelting, tree, mining, horse

# Check if helper is active
execute if entity @e[type=villager,tag=helper.active,limit=1] run function helper:combat_ai

# Trust evaluation (friend/foe detection)
execute if entity @e[type=villager,tag=helper.active,limit=1] run function helper:trust/evaluate

# PVP attack detection: if owner gets hit, attacker becomes instant foe
execute if entity @e[type=villager,tag=helper.active,limit=1] run function helper:trust/detect_attack

# Auto-smelting (every 20 ticks = 1 second)
execute if entity @e[type=villager,tag=helper.active,limit=1] if score #smelt_clock helper_config matches 20 run function helper:smelt/auto_smelt
execute if entity @e[type=villager,tag=helper.active,limit=1] run scoreboard players add #smelt_clock helper_config 1
execute if entity @e[type=villager,tag=helper.active,limit=1] if score #smelt_clock helper_config matches 20.. run scoreboard players set #smelt_clock helper_config 0

# Horse management (every 10 ticks = 0.5 second)
execute if entity @e[type=villager,tag=helper.active,limit=1] if score #horse_clock helper_config matches 10 run function helper:horse/manage
execute if entity @e[type=villager,tag=helper.active,limit=1] run scoreboard players add #horse_clock helper_config 1
execute if entity @e[type=villager,tag=helper.active,limit=1] if score #horse_clock helper_config matches 10.. run scoreboard players set #horse_clock helper_config 0

# Golem structure detection (every 5 ticks)
execute if score #golem_clock helper_config matches 5.. run function helper:golem/check_structures
execute if score #golem_clock helper_config matches 5.. run scoreboard players set #golem_clock helper_config 0
execute run scoreboard players add #golem_clock helper_config 1

# Speed boost: helper always runs at full speed
execute as @e[type=villager,tag=helper.active,limit=1] run effect give @s minecraft:speed 2 1 true
execute as @e[type=villager,tag=helper.active,limit=1] run effect give @s minecraft:swiftness 2 1 true

# Fire resistance (from netherite gear)
execute as @e[type=villager,tag=helper.active,limit=1] run effect give @s minecraft:fire_resistance 4 0 true
