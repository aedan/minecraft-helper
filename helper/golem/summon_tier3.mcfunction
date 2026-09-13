# Tier 3: Netherite Golem - Top Tier Helper
# Requirements: 4 netherite blocks + carved pumpkin + diamond block on top
# Reward: Full netherite gear, 40 HP, max enchantments, all tools, horse

# Check if player already has a helper
execute if entity @e[type=villager,tag=helper.owner=@s,limit=1] run tellraw @s [{"text":"[Helper] ","color":"yellow"},{"text":"You already have a helper! ","color":"gray"},{"text":"Despawn it first with /helper despawn.","color":"red"}]

# Spawn Tier 3 helper (full netherite)
function helper:spawn_helper

# Consume the golem blocks
setblock ~ ~ ~ minecraft:air
setblock ~1 ~ ~ minecraft:air
setblock ~ ~ ~1 minecraft:air
setblock ~1 ~ ~1 minecraft:air
setblock ~ ~1 ~ minecraft:air
setblock ~ ~2 ~ minecraft:air

# Tag the spawned villager as Tier 3
tag @e[type=villager,tag=helper.active,limit=1] add helper.tier3
tag @e[type=villager,tag=helper.active,limit=1] add helper.netherite_golem

# Bind to owner
execute as @a[limit=1] run data modify entity @e[type=villager,tag=helper.active,limit=1] OwnerUUID set value @s

# Set base to player position
execute as @a[limit=1] run scoreboard players set #base_x helper_config < #x
execute as @a[limit=1] run scoreboard players set #base_y helper_config < #y
execute as @a[limit=1] run scoreboard players set #base_z helper_config < #z

# Set owner as friend
execute as @a[limit=1] run scoreboard players set @s trust_level 2
execute as @a[limit=1] run tag @s add helper.friend

# Notify player
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"NETHERITE HELPER SUMMONED! ","color":"dark_purple","bold":true},{"text":"Tier 3 - Ultimate protection. ","color":"gold"},{"text":"Full netherite, max enchants, 40 HP, all tools, horse system.","color":"gray"}]
playsound minecraft:entity.wither.spawn master @s
title @s title [{"text":"HELPER AWAKENED","color":"gold","bold":true}]
title @s subtitle [{"text":"Netherite Golem Tier 3","color":"gray"}]
