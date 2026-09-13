# Golem Summoning System: Players build golem structures to summon helpers
# Tier 1: Stone Golem (basic) - 4 stone blocks + pumpkin
# Tier 2: Iron Golem (advanced) - 4 iron blocks + pumpkin
# Tier 3: Netherite Golem (top tier) - 4 netherite blocks + pumpkin + diamond

# Check for golem structures every 5 ticks
execute store result score #golem_clock helper_config run scoreboard players get #golem_clock helper_config
execute if score #golem_clock helper_config matches 5.. run function helper:golem/check_structures
execute if score #golem_clock helper_config matches 5.. run scoreboard players set #golem_clock helper_config 0
execute run scoreboard players add #golem_clock helper_config 1

# Check each player's position for golem patterns
execute as @a at @s run function helper:golem/check_player_golem
