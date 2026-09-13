# Bow attack: ranged projectile with tracking

# Draw bow (visual)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run playsound minecraft:entity.skeleton.shoot master @s

# Fire arrow at target
execute as @e[type=villager,tag=helper.active,limit=1] at @s run summon arrow ^ ^1.5 ^ {
  "minecraft:owner": {
    "id": -32768
  },
  "pickup": 0,
  "crit": 1,
  "damage": 12.0f,
  "Motion": [0.0d, 0.1d, -1.0d]
}

# Tag the arrow
tag @e[type=arrow,distance=..1,sort=nearest,limit=1] add helper.arrow

# Remove targeted tag after attack to allow re-evaluation
tag @e[type=#minecraft:hostile,tag=helper.targeted,limit=1] remove helper.targeted
