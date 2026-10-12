# As commanding player. Expects @a[tag=helper.hunt_victim] already tagged by brain/RCON.
tag @s add helper.cmd
execute unless entity @a[tag=helper.hunt_victim,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"No target online.","color":"red"}]
execute unless entity @a[tag=helper.hunt_victim,limit=1] run tag @s remove helper.cmd
execute unless entity @a[tag=helper.hunt_victim,limit=1] run return 0

# Refuse hunting yourself
scoreboard players set #self_hunt helper_config 0
execute if entity @s[tag=helper.hunt_victim] run scoreboard players set #self_hunt helper_config 1
execute if score #self_hunt helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"I will not hunt you.","color":"red"}]
execute if score #self_hunt helper_config matches 1 run tag @a remove helper.hunt_victim
execute if score #self_hunt helper_config matches 1 run tag @s remove helper.cmd
execute if score #self_hunt helper_config matches 1 run return 0

# Owner-only: must be helper.owner or already bound (matching helper_id). Never steal binding.
# Check BEFORE id/assign so strangers do not receive a new helper_id.
scoreboard players set #hunt_ok helper_config 0
execute if entity @s[tag=helper.owner] run scoreboard players set #hunt_ok helper_config 1
execute if score #hunt_ok helper_config matches 0 if score @s helper_id matches 1.. if score @s helper_id = @e[tag=helper.active,limit=1] helper_id run scoreboard players set #hunt_ok helper_config 1
execute if score #hunt_ok helper_config matches 0 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Only my owner can order a hunt.","color":"red"}]
execute if score #hunt_ok helper_config matches 0 run tag @a remove helper.hunt_victim
execute if score #hunt_ok helper_config matches 0 run tag @s remove helper.cmd
execute if score #hunt_ok helper_config matches 0 run return 0

function helper:id/assign

# Force job 11 first (keep existing helper_id binding — do not reassign)
scoreboard players set #job helper_config 11
scoreboard players set #gtype helper_config 0
execute as @e[tag=helper.active] run function helper:jobs/force_on_self
execute unless entity @e[tag=helper.active,limit=1] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"You do not have a helper.","color":"red"}]
execute unless entity @e[tag=helper.active,limit=1] run tag @a remove helper.hunt_victim
execute unless entity @e[tag=helper.active,limit=1] run tag @s remove helper.cmd
execute unless entity @e[tag=helper.active,limit=1] run return 0

# Mark the victim after job is set (clear_work already ran inside force_on_self)
tag @a remove helper.hunt_target
tag @a[tag=helper.hunt_victim,limit=1] add helper.hunt_target
tag @a[tag=helper.hunt_victim,limit=1] add helper.foe
tag @a[tag=helper.hunt_victim,limit=1] add helper.priority_target
team leave @a[tag=helper.hunt_victim,limit=1]
tag @a[tag=helper.hunt_victim] remove helper.hunt_victim

tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Hunting ","color":"red"},{"selector":"@a[tag=helper.hunt_target,limit=1]"},{"text":" — traveling on foot/horse, no warp.","color":"gray"}]
tag @s remove helper.cmd
