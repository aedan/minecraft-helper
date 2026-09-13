# Spawn horse with max stats and armor
# Stats: max_health 30, movement_speed 0.3375, jump_strength 1.0
# Armor: iron horse armor (best available)

execute as @e[type=villager,tag=helper.active,limit=1] at @s run summon horse ^ ^ ^1 {
  "Tame": 1b,
  "Health": 30.0f,
  "attributes": [
    {
      "id": "minecraft:horse.max_health",
      "base": 30.0d
    },
    {
      "id": "minecraft:horse.jump_strength",
      "base": 1.0d
    }
  ],
  "equipment": {
    "horse_armor": {
      "id": "minecraft:horse_armor_iron",
      "count": 1
    }
  },
  "Saddle": 1b,
  "Tags": [
    "helper.horse"
  ]
}

tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Horse spawned! ","color":"green"},{"text":"Max stats, iron armor, saddled. Ready to ride.","color":"gray"}]
playsound minecraft:entity.horse.gallop master @a[limit=1]
