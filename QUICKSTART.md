# Quick Start

## Local Game

1. Clone the repo:
   ```bash
   git clone https://github.com/aedan/minecraft-helper.git
   cd minecraft-helper
   ```

2. Package the data pack:
   ```bash
   make package
   ```

3. Copy to your world:
   ```bash
   cp minecraft-helper.datapack.zip ~/.minecraft/saves/<your-world>/datapacks/
   ```

4. In Minecraft:
   ```
   /reload
   ```

5. Build a golem structure to summon your helper:

   **Easiest (Tier 1 - Stone):**
   - Place 4 stone blocks in a 2x2 square
   - Place a carved pumpkin on top
   - Walk next to it
   - Your helper appears!

   **Best (Tier 3 - Netherite):**
   - Place 4 netherite blocks in a 2x2 square
   - Place a carved pumpkin on top
   - Place a diamond block on top of the pumpkin
   - Your netherite protector appears!

6. Use commands to control your helper:
   ```
   /function helper:cmd_set_base    # Mark your base
   /function helper:cmd_stay        # Stay home mode
   /function helper:cmd_fetch       # Go mine diamonds
   /function helper:cmd_watch       # Follow and protect me
   /function helper:cmd_scan        # Scan for ore
   /function helper:cmd_golem_help  # Show the golem guide
   ```

## Server

```bash
# Package
make package

# Deploy
scp minecraft-helper.datapack.zip user@your-server:/path/to/world/datapacks/
```

Then in-game: `/reload`

## Tips

- Your helper remembers your base location. Set it with `/function helper:cmd_set_base`
- Trust other players with `/function helper:cmd_trust` (look at them first)
- Unknown players who open your chests get destroyed
- If anything hits you, the attacker gets destroyed instantly
- The helper builds chests automatically when it returns from a task
- It cuts trees completely and replants them
- It smelts ore and cooks food automatically
- It uses the right tool for every job (pickaxe, shovel, axe)
