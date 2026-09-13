# Spawn the aggressive protector villager with FULL netherrite gear, max enchantments, unbreakable
# 1.21.x custom component syntax

# Set base coordinates to player position (first player)
execute as @a[limit=1] run scoreboard players set #base_x helper_config < #x
execute as @a[limit=1] run scoreboard players set #base_y helper_config < #y
execute as @a[limit=1] run scoreboard players set #base_z helper_config < #z

# Spawn the helper villager
execute as @a[limit=1] at @s run summon villager ^ ^ ^1 {
  "minecraft:type": {
    "id": "minecraft:plains",
    "profession": "minecraft:weaponsmith",
    "level": 3
  },
  "minecraft:persistence_required": {},
  "minecraft:can_pickup_loot": {},
  "minecraft:health": 40.0f,
  "minecraft:components": {
    "minecraft:equipment": {
      "mainhand": {
        "id": "minecraft:netherite_sword",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:sharpness": 10,
            "minecraft:knockback": 2,
            "minecraft:fire_aspect": 2,
            "minecraft:looting": 3,
            "minecraft:sweeping": 3,
            "minecraft:smite": 10,
            "minecraft:bane_of_arthropods": 10
          }
        }
      },
      "offhand": {
        "id": "minecraft:shield",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:unbreaking": 10
          }
        }
      },
      "head": {
        "id": "minecraft:netherite_helmet",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:protection": 4,
            "minecraft:unbreaking": 10,
            "minecraft:blast_protection": 4,
            "minecraft:projectile_protection": 4
          }
        }
      },
      "body": {
        "id": "minecraft:netherite_chestplate",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:protection": 4,
            "minecraft:unbreaking": 10,
            "minecraft:blast_protection": 4,
            "minecraft:projectile_protection": 4
          }
        }
      },
      "legs": {
        "id": "minecraft:netherite_leggings",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:protection": 4,
            "minecraft:unbreaking": 10,
            "minecraft:blast_protection": 4,
            "minecraft:projectile_protection": 4
          }
        }
      },
      "feet": {
        "id": "minecraft:netherite_boots",
        "count": 1,
        "components": {
          "minecraft:damage": 0,
          "minecraft:unbreakable": {},
          "minecraft:enchantments": {
            "minecraft:protection": 4,
            "minecraft:unbreaking": 10,
            "minecraft:blast_protection": 4,
            "minecraft:projectile_protection": 4
          }
        }
      }
    },
    "minecraft:inventory": {
      "items": [
        {
          "id": "minecraft:crossbow",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:unbreakable": {},
            "minecraft:enchantments": {
              "minecraft:mending": 1,
              "minecraft:quick_charge": 3,
              "minecraft:multishot": 1,
              "minecraft:piercing": 4,
              "minecraft:unbreaking": 10,
              "minecraft:flame": 1
            }
          }
        },
        {
          "id": "minecraft:spectral_arrow",
          "count": 64
        },
        {
          "id": "minecraft:netherite_pickaxe",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:unbreakable": {},
            "minecraft:enchantments": {
              "minecraft:efficiency": 10,
              "minecraft:unbreaking": 10,
              "minecraft:mending": 1,
              "minecraft:fortune": 3,
              "minecraft:silk_touch": 1
            }
          }
        },
        {
          "id": "minecraft:netherite_axe",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:unbreakable": {},
            "minecraft:enchantments": {
              "minecraft:sharpness": 10,
              "minecraft:knockback": 2,
              "minecraft:unbreaking": 10,
              "minecraft:mending": 1,
              "minecraft:looting": 3
            }
          }
        },
        {
          "id": "minecraft:netherite_shovel",
          "count": 1,
          "components": {
            "minecraft:damage": 0,
            "minecraft:unbreakable": {},
            "minecraft:enchantments": {
              "minecraft:efficiency": 10,
              "minecraft:unbreaking": 10,
              "minecraft:mending": 1
            }
          }
        },
        {
          "id": "minecraft:golden_apple",
          "count": 32
        },
        {
          "id": "minecraft:ender_pearl",
          "count": 16
        },
        {
          "id": "minecraft:tofu",
          "count": 64
        }
      ]
    },
    "minecraft:fire_immune": {},
    "minecraft:glowing": {},
    "minecraft:attributes": {
      "modifiers": [
        {
          "attribute": "minecraft:generic.max_health",
          "amount": 20.0d,
          "operation": "add_value"
        },
        {
          "attribute": "minecraft:generic.attack_damage",
          "amount": 5.0d,
          "operation": "add_value"
        },
        {
          "attribute": "minecraft:generic.movement_speed",
          "amount": 0.2d,
          "operation": "add_multiplied_base"
        }
      ]
    }
  }
}

# Equip the strongest bow (crossbow with max enchantments is in inventory)
# Also give a power V infinity bow as secondary ranged weapon
execute as @e[type=villager,tag=helper.active,limit=1] at @s run item replace entity @s weapon.offhand with minecraft:bow{Components:{"minecraft:damage":0,"minecraft:unbreakable":{},"minecraft:enchantments":{"minecraft:power":5,"minecraft:punch":3,"minecraft:infinity":1,"minecraft:flame":1,"minecraft:mending":1,"minecraft:unbreaking":10}}}

# Tag the spawned villager
tag @e[type=villager,limit=1] add helper.active
tag @e[type=villager,tag=helper.active,limit=1] add helper.spawned
tag @e[type=villager,tag=helper.active,limit=1] add helper.protector
tag @e[type=villager,tag=helper.active,limit=1] add helper.hybrid_combat
tag @e[type=villager,tag=helper.active,limit=1] add helper.netherite_gear

# Notify player
tellraw @a[limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Netherite Protector spawned! ","color":"gold"},{"text":"Full netherrite gear, max enchants, unbreakable, 2x inventory, 40 HP.","color":"green"},{"text":"\n","color":"gray"},{"text":"Use /helper <mode> to control it.","color":"gray"}]
playsound minecraft:entity.wither.spawn master @a[limit=1]
title @a[limit=1] title [{"text":"HELPER DEPLOYED","color":"gold","bold":true}]
title @a[limit=1] subtitle [{"text":"Netherite Protger Online","color":"gray"}]
