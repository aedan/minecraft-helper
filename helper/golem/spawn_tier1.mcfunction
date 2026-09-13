# Spawn Tier 1 Helper: Wooden gear, 20 HP, basic combat
# Wooden sword, wooden pickaxe, wooden shovel, wooden axe
# No armor, no bow, basic speed

execute as @a[limit=1] at @s run summon villager ^ ^ ^1 {
  "minecraft:type": {
    "id": "minecraft:plains",
    "profession": "minecraft:farmer",
    "level": 1
  },
  "minecraft:persistence_required": {},
  "minecraft:can_pickup_loot": {},
  "minecraft:health": 20.0f,
  "minecraft:components": {
    "minecraft:equipment": {
      "mainhand": {
        "id": "minecraft:wooden_sword",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:enchantments": {
            "minecraft:sharpness": 1
          }
        }
      }
    },
    "minecraft:inventory": {
      "items": [
        {
          "id": "minecraft:wooden_pickaxe",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:enchantments": {
              "minecraft:efficiency": 1
            }
          }
        },
        {
          "id": "minecraft:wooden_shovel",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:enchantments": {
              "minecraft:efficiency": 1
            }
          }
        },
        {
          "id": "minecraft:wooden_axe",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:enchantments": {
              "minecraft:sharpness": 1
            }
          }
        },
        {
          "id": "minecraft:bread",
          "count": 16
        }
      ]
    },
    "minecraft:glowing": {}
  }
}

# Tag the spawned villager as Tier 1 and bind to owner
tag @e[type=villager,limit=1] add helper.active
tag @e[type=villager,limit=1] add helper.tier1
tag @e[type=villager,limit=1] add helper.wooden_gear
execute as @a[limit=1] run data modify entity @e[type=villager,limit=1] OwnerUUID set value @s

# Set base to player position
execute as @a[limit=1] run scoreboard players set #base_x helper_config < #x
execute as @a[limit=1] run scoreboard players set #base_y helper_config < #y
execute as @a[limit=1] run scoreboard players set #base_z helper_config < #z

# Set owner as friend
execute as @a[limit=1] run scoreboard players set @s trust_level 2
execute as @a[limit=1] run tag @s add helper.friend
