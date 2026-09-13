# Minecraft AI Helper

An aggressive protector villager for Minecraft 1.21.x — built entirely with vanilla commands and data packs. No mods, no external dependencies.

The helper is a fully autonomous AI companion that fights, mines, crafts, organizes storage, manages smelting, and defends you from all threats. Summon it by building a golem structure — no admin commands needed.

## Features

### Combat
- **Hybrid AI**: Sword at close range (≤3 blocks), bow at range (12-24 blocks), strafe in between
- **Owner priority**: Automatically switches to defend you when threats approach within 16 blocks
- **PVP detection**: If anything hits you, the attacker becomes an instant foe and gets destroyed
- **Trust system**: Friends (you + trusted players) can access chests. Unknowns who open chests are killed. Hostiles don't make it past the perimeter

### Three Summoning Tiers
Build a golem structure to summon your helper. Higher tiers = more powerful.

| Tier | Structure | Gear | HP | Special |
|------|-----------|------|-----|---------|
| **1 - Stone** | 4 stone + pumpkin | Wooden tools, sword | 20 | Basic protection |
| **2 - Iron** | 4 iron blocks + pumpkin | Full iron armor, sword + bow | 30 | Fire immune |
| **3 - Netherite** | 4 netherite blocks + pumpkin + diamond block | Full netherite, max enchants, unbreakable | 40 | Horse system, all tools |

### Behavior Modes
- **Stay Home**: Patrols base, returns if strayed more than 32 blocks
- **Fetch Resource**: Wanders to find and mine diamonds, returns to base
- **Watch Back**: Follows you within 4 blocks, protects at all costs

### Economy & Logistics
- **Chest organization**: Builds labeled chests at base, sorts items by category
- **Storage area**: 16x16 zone with 16 categorized chests (Iron, Gold, Diamond, Netherite, Coal, Redstone, Lapis, Emerald, Food, Raw Food, Cooked, Tools, Weapons, Armor, Blocks, Misc)
- **Auto-smelting**: Builds furnace + smoker + blast furnace, loads ore, finds fuel (cuts trees, replants)
- **Tree cutting**: Completely fells trees, collects logs, replants saplings
- **Intelligent mining**: Uses correct tool for each block (pickaxe for stone, shovel for dirt, axe for wood), repairs walls it breaks

### Horse System
- Detects when you mount a horse
- Spawns a max-stat horse (30 HP, iron armor, saddled) if you need one
- Despawns the horse when you get off

### Always Active
- Speed II + Swiftness II (never gets tired)
- Fire Resistance
- 40 HP (netherite tier)

## Installation

### Quick Start
```bash
# Clone the repo
git clone https://github.com/aedan/minecraft-helper.git
cd minecraft-helper

# Package the data pack
make package

# Copy to your world
cp minecraft-helper.datapack.zip ~/.minecraft/saves/<world>/datapacks/

# In Minecraft
/reload
```

### For a Server
```bash
scp minecraft-helper.datapack.zip user@server:/path/to/world/datapacks/
# Then in-game: /reload
```

## Commands

All commands work for admins. Players summon helpers by building golem structures.

| Command | Description |
|---------|-------------|
| `/function helper:cmd_spawn` | Spawn netherite helper (admin only) |
| `/function helper:cmd_despawn` | Remove your helper |
| `/function helper:cmd_stay` | Set mode: Stay Home |
| `/function helper:cmd_fetch` | Set mode: Fetch Resource |
| `/function helper:cmd_watch` | Set mode: Watch Back |
| `/function helper:cmd_set_base` | Mark current location as base |
| `/function helper:cmd_set_storage` | Mark 16x16 area as storage zone |
| `/function helper:cmd_trust` | Trust the player you're looking at |
| `/function helper:cmd_untrust` | Remove trust from a player |
| `/function helper:cmd_scan` | Scan for ore in 32-block radius |
| `/function helper:cmd_craft` | Request an item to be crafted |
| `/function helper:cmd_golem_help` | Show golem building guide |

## Golem Structures

Build these to summon a helper. The data pack detects them automatically.

### Tier 1: Stone Helper
```
    [Pumpkin]
    [Stone] [Stone]
    [Stone] [Stone]
```
Place a carved pumpkin on top of a 2x2 stone square.

### Tier 2: Iron Helper
```
    [Pumpkin]
    [Iron] [Iron]
    [Iron] [Iron]
```
Place a carved pumpkin on top of a 2x2 iron block square.

### Tier 3: Netherite Helper
```
    [Diamond]
    [Pumpkin]
    [Netherite] [Netherite]
    [Netherite] [Netherite]
```
Place a diamond block on top of a carved pumpkin on top of a 2x2 netherite block square.

**Rules:**
- One helper per player
- Blocks are consumed when summoned
- Despawn with `/function helper:cmd_despawn` to summon a higher tier

## Architecture

```
datapack/
├── pack.mcmeta                    # Pack manifest (format 48)
├── data/
│   ├── minecraft/tags/function/
│   │   ├── load.json              # Runs helper:load on /reload
│   │   └── tick.json              # Runs helper:tick every tick
│   └── helper/function/
│       ├── load.mcfunction        # Initialize scoreboards, set owner as friend
│       ├── tick.mcfunction        # Main AI loop (combat, trust, smelt, horse, golem)
│       ├── combat_ai.mcfunction   # Combat entry point
│       ├── spawn_helper.mcfunction# Spawn netherite helper (admin)
│       ├── cmd_*.mcfunction       # Player commands
│       ├── combat/                # Combat AI (24 functions)
│       ├── trust/                 # Friend/foe detection (11 functions)
│       ├── chest/                 # Chest organization (5 functions)
│       ├── storage/               # Storage area (4 functions)
│       ├── smelt/                 # Auto-smelting (5 functions)
│       ├── tree/                  # Tree cutting (5 functions)
│       ├── mine/                  # Intelligent mining (7 functions)
│       ├── horse/                 # Horse management (3 functions)
│       └── golem/                 # Golem summoning (7 functions)
└── gen/                           # Python generator (source of truth)
    ├── mansions_gen.py
    └── ...
```

### Scoreboard Objectives

| Objective | Purpose |
|-----------|---------|
| `helper_config` | Global config: base coords, mode, fetch target, clocks |
| `helper_combat` | Combat: target ID, threat coords, distance |
| `trust_level` | Per-player trust: 0=foe, 1=unknown, 2=friend |

### AI Decision Flow

```
Every tick:
├── combat_ai
│   ├── Hostile within 24 blocks?
│   │   ├── Yes → find_target
│   │   │   ├── Owner within 16 blocks of hostile? → defend_owner
│   │   │   │   ├── ≤3 blocks → sword_attack
│   │   │   │   ├── 4-11 blocks → strafe
│   │   │   │   └── 12-24 blocks → bow_attack
│   │   │   └── No → engage_target (same distance logic)
│   │   └── No → idle_behavior
│   │       ├── Mode 1 (Stay Home) → patrol_base / return_to_base
│   │       ├── Mode 2 (Fetch) → search_resource → mine → return_to_base
│   │       └── Mode 3 (Watch Back) → chase_owner / stand_guard
│   └── trust/evaluate
│       ├── Perimeter check (16 blocks)
│       ├── Chest access check (unknowns → kill)
│       ├── Hostile threat (24 blocks → destroy)
│       └── detect_attack (owner HurtTime > 0 → find_attacker → kill)
├── Every 20 ticks: smelt/auto_smelt
├── Every 10 ticks: horse/manage
└── Every 5 ticks: golem/check_structures
```

## Requirements

- Minecraft Java Edition 1.21.x
- No mods required
- No external dependencies

## Development

```bash
# Run the generator
python3 gen/mansions_gen.py

# Package the data pack
make package

# Deploy to dev server
make deploy
```

## License

MIT
