# Spawn helper: create the aggressive protector villager

# Check if helper already exists
execute unless entity @e[type=villager,tag=helper.active,limit=1] run function helper:spawn_helper
execute if entity @e[type=villager,tag=helper.active,limit=1] run tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Helper already exists.","color":"red"}]
