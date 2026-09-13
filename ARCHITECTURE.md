# Architecture

## Design Philosophy

The helper is built entirely with vanilla Minecraft commands and data packs. No mods, no external libraries, no Java. All logic is expressed in `.mcfunction` files and scoreboard operations.

The Python generator (`gen/mansions_gen.py`) is the canonical source. It emits all `.mcfunction` files, scoreboard JSON, tags, and `pack.mcmeta`. Edit the generator, not the generated files.

## Module Breakdown

### 1. Combat AI (`combat/`)

The combat system is a hybrid: high-level state machine + lightweight distance-based decision making.

**Detection:** Every tick, scans for hostile mobs within 24 blocks using `@e[type=#minecraft:hostile,distance=..24,sort=nearest,limit=1]`.

**Priority:** If a hostile is within 16 blocks of the owner, the helper switches to `defend_owner` mode. Otherwise it engages the target directly.

**Distance-based actions:**
- ≤3 blocks: `sword_attack` — melee strike with knockback
- 4-11 blocks: `strafe` — perpendicular movement to avoid attacks
- 12-24 blocks: `bow_attack` — fire arrow with 12 damage (crit)

**Targeting:** Uses `sort=nearest` entity selectors. The target is tagged `helper.targeted` for tracking.

### 2. Trust System (`trust/`)

Three trust levels:
- **0 (Foe):** Destroyed on sight. Players who attack the owner or open chests as unknowns.
- **1 (Unknown):** Can enter the base but cannot open chests. If they do, they become a foe.
- **2 (Friend):** Full access. Owner + trusted players.

**Detection flow:**
1. `check_perimeter` — flags unknowns entering 16-block radius
2. `check_chest_access` — if unknown is near a chest → `make_foe` (kill)
3. `hostile_threat` — hostiles within 24 blocks → `engage_hostile` (destroy)
4. `detect_attack` — if owner's `HurtTime > 0` → `find_attacker` → kill attacker

### 3. Chest Organization (`chest/`, `storage/`)

**Base chests:** 5 labeled chests (Supplies, Resources, Food, Tools, Misc) built at the base when the helper returns from a task.

**Storage area:** 16x16 zone with 16 categorized chests. Built on demand with `/function helper:cmd_set_storage`.

**Sorting:** Items from the helper's inventory are transferred to chests using `data modify block ... Items set from entity ... Inventory`.

### 4. Auto-Smelting (`smelt/`)

Runs every 20 ticks (1 second).

1. Check for furnace within 8 blocks of base
2. If no furnace, build furnace + smoker + blast furnace with hoppers
3. Check inventory for fuel (wood, coal, charcoal, blaze rods)
4. If no fuel, go find wood (cuts tree, replants)
5. Load ore into furnace, add fuel, start smelting

### 5. Tree Cutting (`tree/`)

1. Find nearest tree within 32 blocks (oak, spruce, or birch)
2. Break all logs (axe) and leaves
3. Collect 16 logs
4. Replant sapling at cut location

### 6. Intelligent Mining (`mine/`)

Context-aware tool selection:
- Stone/ore → pickaxe
- Dirt/gravel → shovel
- Wood → axe

After mining, checks if a wall was broken. If adjacent blocks are stone, replaces the broken block with stone.

`/function helper:cmd_scan` scans a 32-block radius for all ore types (iron, gold, diamond, coal, redstone, lapis, copper) and reports findings.

### 7. Horse System (`horse/`)

Runs every 10 ticks (0.5 second).

1. Check if owner is riding a horse (`data get entity @s Vehicle[0]`)
2. If yes and helper doesn't have a horse → spawn max-stat horse (30 HP, iron armor, saddled)
3. If no and helper has a horse → despawn it

### 8. Golem Summoning (`golem/`)

Checks for golem structures every 5 ticks.

**Detection:** Scans the 2x2 block area around each player for:
- Tier 1: 4 stone + pumpkin on top
- Tier 2: 4 iron blocks + pumpkin on top
- Tier 3: 4 netherite blocks + pumpkin + diamond block on top

When detected:
1. Check if player already has a helper (reject if so)
2. Spawn the appropriate tier
3. Consume the golem blocks
4. Bind helper to owner (`OwnerUUID`)
5. Set base to player position
6. Mark owner as friend

## Scoreboard Design

| Objective | Fake Players | Purpose |
|-----------|-------------|---------|
| `helper_config` | `#base_x/y/z` | Base coordinates |
| | `#mode` | 0=none, 1=stay, 2=fetch, 3=watch |
| | `#fetch_target` | What to mine (1=diamond) |
| | `#storage_x/y/z` | Storage area center |
| | `#storage_set` | 1 if storage area is set |
| | `#smelt_clock` | 0-20 tick counter |
| | `#horse_clock` | 0-10 tick counter |
| | `#golem_clock` | 0-5 tick counter |
| `helper_combat` | `#target_id` | Current target |
| | `#threat_x/y/z` | Threat position |
| | `#owner_x/y/z` | Owner position |
| | `#dist` | Distance to threat |
| `trust_level` | `@p` (per player) | 0=foe, 1=unknown, 2=friend |

## Tick Loop

```
tick.mcfunction (every tick)
├── combat_ai (if helper active)
│   ├── decide_action
│   │   ├── Hostile in 24 blocks? → find_target
│   │   └── No hostile → idle_behavior (mode-based)
│   └── trust/evaluate
│       ├── check_perimeter
│       ├── check_chest_access
│       ├── hostile_threat
│       └── detect_attack (HurtTime > 0)
├── smelt/auto_smelt (every 20 ticks)
├── horse/manage (every 10 ticks)
├── golem/check_structures (every 5 ticks)
├── effect give speed 2 (every tick)
├── effect give swiftness 2 (every tick)
└── effect give fire_resistance 4 (every tick)
```

## File Count

| Module | Files |
|--------|-------|
| Combat | 24 |
| Trust | 11 |
| Chest/Storage | 9 |
| Smelting | 5 |
| Tree | 5 |
| Mining | 7 |
| Horse | 3 |
| Golem | 7 |
| Commands | 12 |
| Core (load/tick/spawn) | 3 |
| **Total** | **~86** |
