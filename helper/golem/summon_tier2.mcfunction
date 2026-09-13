# Tier 2: Iron Golem - Advanced Helper
# Requirements: 4 iron blocks + carved pumpkin
# Reward: Iron gear, 30 HP, sword + bow, moderate enchantments

# Check if player already has a helper
execute if entity @e[type=villager,tag=helper.owner=@s,limit=1] run tellraw @s [{"text":"[Helper] ","color":"yellow"},{"text":"You already have a helper! ","color":"gray"},{"text":"Despawn it first with /helper despawn.","color":"red"}]

# Spawn Tier 2 helper
function helper:golem/spawn_tier2

# Consume the golem blocks
setblock ~ ~ ~ minecraft:air
setblock ~1 ~ ~ minecraft:air
setblock ~ ~ ~1 minecraft:air
setblock ~1 ~ ~1 minecraft:air
setblock ~ ~1 ~ minecraft:air

# Notify player
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"IRON HELPER SUMMONED! ","color":"gray","bold":true},{"text":"Tier 2 - Advanced protection. ","color":"gold"},{"text":"Iron gear, 30 HP, sword + bow.","color":"gray"}]
playsound minecraft:entity.iron_golem.repair master @s
