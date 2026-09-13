# Tier 1: Stone Golem - Basic Helper
# Requirements: 4 stone blocks + carved pumpkin
# Reward: Wooden gear, 20 HP, basic combat only

# Check if player already has a helper
execute if entity @e[type=villager,tag=helper.owner=@s,limit=1] run tellraw @s [{"text":"[Helper] ","color":"yellow"},{"text":"You already have a helper! ","color":"gray"},{"text":"Despawn it first with /helper despawn.","color":"red"}]

# Check if player is in a valid location (not in base of another player)
# For now, just spawn the helper

# Spawn Tier 1 helper (wooden gear, basic stats)
function helper:golem/spawn_tier1

# Consume the golem blocks (break them)
setblock ~ ~ ~ minecraft:air
setblock ~1 ~ ~ minecraft:air
setblock ~ ~ ~1 minecraft:air
setblock ~1 ~ ~1 minecraft:air
setblock ~ ~1 ~ minecraft:air

# Notify player
tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"STONE HELPER SUMMONED! ","color":"gray","bold":true},{"text":"Tier 1 - Basic protection. ","color":"yellow"},{"text":"Wooden gear, 20 HP, sword only.","color":"gray"}]
playsound minecraft:entity.iron_golem.hurt master @s
