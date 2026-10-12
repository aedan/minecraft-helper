# Architecture

## Design Philosophy

The helper is built entirely with vanilla Minecraft commands and data packs. No mods, no external libraries, no Java. All logic is expressed in `.mcfunction` files and scoreboard operations.

`datapack/` is the source of truth and is edited by hand. `make package` zips it as-is. The top-level `helper/` tree is an older copy that is not packaged. `gen/mansions_gen.py` writes only to `gen/` for a separate Mansions defense pack and does not generate this pack.

A Python sidecar (`sidecar/helper_brain.py`) tails the server log for chat, reads the private-order inbox (`/function helper:w`, `/trigger tom`), and drives the helper over RCON by calling `helper:jobs/*`, `helper:cmd_here`, and `helper:lifecycle/apply_bound_name`.

## Module Breakdown

### 1. Combat AI (`combat/`)

The combat system is a hybrid: high-level state machine + lightweight distance-based decision making.

**Targeting:** `combat/pick_seen` picks the nearest threat with line of sight (`combat/los_check`), trying up to 8 candidates. The target is tagged `helper.targeted`.

**Priority:** `combat/defend_owner` prefers `helper.priority_target` (whoever hit the owner, see `trust/detect_attack`), then a hunt target, then hostiles near the owner.

**Actions:** `combat/fight` uses `sword_attack` up close, `mid_range`/`strafe` in between, and `bow_attack` at range. `combat/dodge` raises the shield and sidesteps incoming projectiles.

### 2. Trust System (`trust/`)

Only attacker detection is active: `trust/detect_attack` reads the owner's `HurtTime` and tags the attacker (`mark_attacker`) as `helper.priority_target`.

The perimeter/chest-access trust system was removed. `cmd_trust`/`cmd_untrust` still set the `helper.friend` tag and `trust_level` score, but nothing reads them.

### 3. Chest Organization (`chest/`, `storage/`)

The old base-chest and storage-grid sorting code was never called and has been removed. Chest placement and item deposit now happen in jobs (`jobs/place_chest`, `jobs/dig_deposit`, `jobs/fill_nearest_chest`). `cmd_set_storage` records a storage center that nothing reads yet.

### 4. Auto-Smelting (`smelt/`)

Passive auto-smelting is off. Smelting runs as job 9 (`jobs/smelt_job`), which builds a furnace once at the base (`smelt/build_furnace_once`) and loads it (`smelt/load_for_job`).

### 5. Tree Cutting (`tree/`)

Tree cutting runs as job 5 (`jobs/cut_trees`): `tree_scan` → `fell_tree`/`fell_logs` → `strip_canopy` → `vacuum_logs` → `replant_stump`. The old `tree/` functions were removed.

### 6. Intelligent Mining (`mine/`)

Mining is done by jobs (`jobs/dig_*`, `jobs/break_vein`, `mine/break_here`, `mine/scan_near`); tools are held via `spawn/hold_*`. The old `mine/intelligent_mine` tool-selection path was never called and has been removed.

`/function helper:cmd_scan` calls `mine/locate_ore`, which only probes 4 adjacent blocks (not a 32-block radius).

### 7. Horse System (`horse/`)

Runs every helper tick (`horse/tick`, skipped during hunt job 11).

1. If the owner is riding a `#helper:mounts` entity and the helper is not mounted → `horse/ensure` (mount an existing helper horse or spawn one)
2. If the owner is on foot and the helper owns a horse → `horse/despawn_horse`

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
| | `#golem_clock` | 0-5 tick counter |
| `helper_combat` | `#target_id` | Current target |
| | `#threat_x/y/z` | Threat position |
| | `#owner_x/y/z` | Owner position |
| | `#dist` | Distance to threat |
| `trust_level` | per player | Set by `cmd_trust`/`cmd_untrust`; not created in `load` and not read |

## Tick Loop

```
tick.mcfunction (every tick, #minecraft:tick)
├── golem/check_structures (every 5 ticks, every player)
├── as each @e[tag=helper.active] → helper_tick
│   ├── tag owner helper.my_owner, memory/snapshot, chunk forceload refresh
│   ├── lifecycle/ensure_name, jobs/tick (instant jobs 1-4), horse/tick, move/gravity
│   ├── trust/detect_attack, combat/calm_golems, combat/dodge
│   ├── target selection (raid_select / pick_seen / pick_food), combat/defend_owner
│   ├── combat/fight
│   ├── long jobs 5-15 (cut_trees, place_chest, raid, dig, smelt, craft, hunt,
│   │   lay_rails, clear_wall_torches, clear_rails, repair_rails)
│   └── idle: follow/keep_up or combat/idle_behavior (stay / fetch / watch)
├── as @a[helper_want=1] → lifecycle/owner_tick (recall, forceload recovery, respawn)
└── /trigger helper_cmd 1-9 and /trigger tom dispatch
```

The sidecar adds work asynchronously over RCON (`jobs/enqueue`, `jobs/force`, `jobs/*_start`).
