# Label chests by category (simplified: label first 16 chests)

# Iron Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-8 ~ ~-8 {front_text:{messages:[{"text":"Iron","color":"gray","bold":true}]}}
# Gold Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-6 ~ ~-8 {front_text:{messages:[{"text":"Gold","color":"yellow","bold":true}]}}
# Diamond Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-4 ~ ~-8 {front_text:{messages:[{"text":"Diamond","color":"aqua","bold":true}]}}
# Netherite Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-2 ~ ~-8 {front_text:{messages:[{"text":"Netherite","color":"dark_purple","bold":true}]}}
# Coal Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-8 ~ ~-6 {front_text:{messages:[{"text":"Coal","color":"black","bold":true}]}}
# Redstone Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-6 ~ ~-6 {front_text:{messages:[{"text":"Redstone","color":"red","bold":true}]}}
# Lapis Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-4 ~ ~-6 {front_text:{messages:[{"text":"Lapis","color":"blue","bold":true}]}}
# Emerald Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-2 ~ ~-6 {front_text:{messages:[{"text":"Emerald","color":"green","bold":true}]}}
# Food Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-8 ~ ~-4 {front_text:{messages:[{"text":"Food","color":"gold","bold":true}]}}
# Raw Food
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-6 ~ ~-4 {front_text:{messages:[{"text":"Raw Food","color":"dark_red","bold":true}]}}
# Cooked Food
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-4 ~ ~-4 {front_text:{messages:[{"text":"Cooked","color":"yellow","bold":true}]}}
# Tools Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-2 ~ ~-4 {front_text:{messages:[{"text":"Tools","color":"blue","bold":true}]}}
# Weapons Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-8 ~ ~-2 {front_text:{messages:[{"text":"Weapons","color":"red","bold":true}]}}
# Armor Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-6 ~ ~-2 {front_text:{messages:[{"text":"Armor","color":"gray","bold":true}]}}
# Blocks Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-4 ~ ~-2 {front_text:{messages:[{"text":"Blocks","color":"brown","bold":true}]}}
# Misc Storage
execute as @e[type=villager,tag=helper.active,limit=1] at @s run data merge block ~-2 ~ ~-2 {front_text:{messages:[{"text":"Misc","color":"light_purple","bold":true}]}}
