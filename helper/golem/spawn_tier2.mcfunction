# Spawn Tier 2 Helper: Iron gear, 30 HP, sword + bow
# Iron sword (sharpness 2), iron pickaxe (efficiency 2), iron shovel, iron axe
# Iron armor (protection 1), bow (power 1)
# Moderate speed, basic smelting

execute as @a[limit=1] at @s run summon villager ^ ^ ^1 {
  "minecraft:type": {
    "id": "minecraft:plains",
    "profession": "minecraft:toolsmith",
    "level": 2
  },
  "minecraft:persistence_required": {},
  "minecraft:can_pickup_loot": {},
  "minecraft:health": 30.0f,
  "minecraft:components": {
    "minecraft:equipment": {
      "mainhand": {
        "id": "minecraft:iron_sword",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:sharpness": 2,
            "minecraft:knockback": 1
          }
        }
      },
      "offhand": {
        "id": "minecraft:bow",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:power": 1
          }
        }
      },
      "head": {
        "id": "minecraft:iron_helmet",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:protection": 1
          }
        }
      },
      "body": {
        "id": "minecraft:iron_chestplate",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:protection": 1
          }
        }
      },
      "legs": {
        "id": "minecraft:iron_leggings",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:protection": 1
          }
        }
      },
      "feet": {
        "id": "minecraft:iron_boots",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:protection": 1
          }
        }
      }
    },
    "minecraft:inventory": {
      "items": [
        {
          "id": "minecraft:iron_pickaxe",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:unbreakable": {},
            "minecraft:enchantments": {
              "minecraft:efficiency": 2,
              "minecraft:unbreaking": 1
            }
          }
        },
        {
          "id": "minecraft:iron_shovel",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:unbreakable": {},
            "minecraft:enchantments": {
              "minecraft:efficiency": 2
            }
          }
        },
        {
          "id": "minecraft:iron_axe",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:unbreakable": {},
            "minecraft:enchantments": {
              "minecraft:sharpness": 2
            }
          }
        },
        {
          "id": "minecraft:arrow",
          "count": 32
        },
        {
          "id": "minecraft:cooked_beef",
          "count": 16
        }
      ]
    },
    "minecraft:fire_immune": {},
    "minecraft:glowing": {}
  }
}

# Tag the spawned villager as Tier 2 and bind to owner
tag @e[type=villager,limit=1] add helper.active
tag @e[type=villager,limit=1] add helper.tier2
tag @e[type=villager,limit=1] add helper.iron_gear
execute as @a[limit=1] run data modify entity @e[type=villager,limit=1] OwnerUUID set value @s

# Set base to player position
execute as @a[limit=1] run scoreboard players set #base_x helper_config < #x
execute as @a[limit=1] run scoreboard players set #base_y helper_config < #y
execute as @a[limit=1] run scoreboard players set #base_z helper_config < #z

# Set owner as friend
execute as @a[limit=1] run scoreboard players set @s trust_level 2
execute as @a[limit=1] run tag @s add helper.friend

# Give speed effect
execute as @e[type=villager,tag=helper.tier2,limit=1] run effect give @s minecraft:speed 1 0 true
