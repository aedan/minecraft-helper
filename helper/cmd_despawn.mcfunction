# Despawn helper: remove the villager

# Remove all active helpers
kill @e[type=villager,tag=helper.active]

# Reset mode
scoreboard players set #mode helper_config 0

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Helper despawned.","color":"red"}]
playsound minecraft:entity.villager.no master @a[limit=1]
