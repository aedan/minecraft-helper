# Quick Start

## Install

```bash
make package
cp minecraft-helper.datapack.zip ~/.minecraft/saves/<world>/datapacks/
```

In Minecraft: `/reload`

You should see: `AI Helper loaded.`

## Summon

Walk next to a golem structure. Blocks are consumed on success.

**Tier 1 — Stone:** 2×2 stone, carved pumpkin on top. Wooden sword + bow.

**Tier 2 — Iron:** 2×2 iron blocks, carved pumpkin on top. Iron gear, sword, bow, shield.

**Tier 3 — Netherite:** 2×2 netherite blocks, carved pumpkin on top, diamond block on the pumpkin. Full netherite, sword, bow, shield.

Admin shortcut: `/function helper:cmd_spawn`

One helper per player. Despawn before building a higher tier.

## Orders

The helper follows and protects you as soon as it spawns (Watch Back).

Clickable list: `/function helper:cmd_golem_help`

Or:

| Order | Function | Trigger |
|---|---|---|
| Follow and protect | `/function helper:cmd_watch` | `/trigger helper_cmd set 3` |
| Patrol base | `/function helper:cmd_stay` | `/trigger helper_cmd set 1` |
| Mine nearby diamonds | `/function helper:cmd_fetch` | `/trigger helper_cmd set 2` |
| Mark this spot as base | `/function helper:cmd_set_base` | `/trigger helper_cmd set 4` |
| Despawn | `/function helper:cmd_despawn` | `/trigger helper_cmd set 5` |

## Combat and horse

- Close: sword. Mid: strafe and close. Far: bow.
- Shield raises (resistance) when arrows or fireballs come in; the helper sidesteps.
- Hostiles near you are prioritized.
- If you take damage, the attacker is hunted.
- Mount a horse: the helper spawns its own saddled horse, mounts, and follows. Dismount: it gets off and that horse despawns.

## Tips

- `/function helper:cmd_set_base` before Stay Home, or the helper will follow you instead.
- Fetch only breaks diamond ore it walks next to (including deepslate). It does not tunnel to Y=-59 by itself.
- Smelting, chest sorting, and auto-crafting are not wired up yet.
