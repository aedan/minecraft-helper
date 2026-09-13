# Hybrid combat AI: bow at range, sword at close, strafe behavior, prioritize protecting owner
# Runs every tick for each active helper

# Check if there's an owner to protect (first player within 32 blocks)
execute as @e[type=villager,tag=helper.active,limit=1] at @s run function helper:combat/decide_action
