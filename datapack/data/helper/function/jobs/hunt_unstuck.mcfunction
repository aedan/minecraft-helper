# Strong unstuck: never remain inside solid after dig / horse despawn / path error.
# 1) Remember last safe air (feet+head clear). 2) Carve 3-tall pocket. 3) Probe nearby air.
# 4) Fall back to last safe pos. Micro-adjust only — never warp onto hunt victim.

# Record safe standing position when currently clear
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run scoreboard players operation @s helper_lx = @s helper_hx
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run scoreboard players operation @s helper_ly = @s helper_hy
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run scoreboard players operation @s helper_lz = @s helper_hz

# Already clear at feet+head → done
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run return 0

# Carve a 1x3 air column at feet (feet, head, margin above)
execute at @s unless block ~ ~ ~ minecraft:bedrock unless block ~ ~ ~ minecraft:barrier unless block ~ ~ ~ #helper:passable run setblock ~ ~ ~ air destroy
execute at @s unless block ~ ~1 ~ minecraft:bedrock unless block ~ ~1 ~ minecraft:barrier unless block ~ ~1 ~ #helper:passable run setblock ~ ~1 ~ air destroy
execute at @s unless block ~ ~2 ~ minecraft:bedrock unless block ~ ~2 ~ minecraft:barrier unless block ~ ~2 ~ #helper:passable run setblock ~ ~2 ~ air destroy

# Widen to a small room so mannequin hitbox is free (cardinals at feet+head)
execute at @s unless block ~1 ~ ~ minecraft:bedrock unless block ~1 ~ ~ minecraft:barrier unless block ~1 ~ ~ #helper:passable run setblock ~1 ~ ~ air destroy
execute at @s unless block ~-1 ~ ~ minecraft:bedrock unless block ~-1 ~ ~ minecraft:barrier unless block ~-1 ~ ~ #helper:passable run setblock ~-1 ~ ~ air destroy
execute at @s unless block ~ ~ ~1 minecraft:bedrock unless block ~ ~ ~1 minecraft:barrier unless block ~ ~ ~1 #helper:passable run setblock ~ ~ ~1 air destroy
execute at @s unless block ~ ~ ~-1 minecraft:bedrock unless block ~ ~ ~-1 minecraft:barrier unless block ~ ~ ~-1 #helper:passable run setblock ~ ~ ~-1 air destroy
execute at @s unless block ~1 ~1 ~ minecraft:bedrock unless block ~1 ~1 ~ minecraft:barrier unless block ~1 ~1 ~ #helper:passable run setblock ~1 ~1 ~ air destroy
execute at @s unless block ~-1 ~1 ~ minecraft:bedrock unless block ~-1 ~1 ~ minecraft:barrier unless block ~-1 ~1 ~ #helper:passable run setblock ~-1 ~1 ~ air destroy
execute at @s unless block ~ ~1 ~1 minecraft:bedrock unless block ~ ~1 ~1 minecraft:barrier unless block ~ ~1 ~1 #helper:passable run setblock ~ ~1 ~1 air destroy
execute at @s unless block ~ ~1 ~-1 minecraft:bedrock unless block ~ ~1 ~-1 minecraft:barrier unless block ~ ~1 ~-1 #helper:passable run setblock ~ ~1 ~-1 air destroy

# If clear now, done
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run return 0

# Step up into air column above
execute at @s if block ~ ~1 ~ #helper:passable if block ~ ~2 ~ #helper:passable run tp @s ~ ~1 ~
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run return 0

# Probe cardinal safe air (2-tall) within 1 block
execute at @s if block ~1 ~ ~ #helper:passable if block ~1 ~1 ~ #helper:passable run tp @s ~1 ~ ~
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run return 0
execute at @s if block ~-1 ~ ~ #helper:passable if block ~-1 ~1 ~ #helper:passable run tp @s ~-1 ~ ~
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run return 0
execute at @s if block ~ ~ ~1 #helper:passable if block ~ ~1 ~1 #helper:passable run tp @s ~ ~ ~1
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run return 0
execute at @s if block ~ ~ ~-1 #helper:passable if block ~ ~1 ~-1 #helper:passable run tp @s ~ ~ ~-1
execute at @s if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run return 0

# Last resort: return to last recorded safe air (not onto victim)
execute if score @s helper_lx = @s helper_lx store result storage helper:safe x int 1 run scoreboard players get @s helper_lx
execute if score @s helper_ly = @s helper_ly store result storage helper:safe y int 1 run scoreboard players get @s helper_ly
execute if score @s helper_lz = @s helper_lz store result storage helper:safe z int 1 run scoreboard players get @s helper_lz
execute if score @s helper_lx = @s helper_lx run function helper:jobs/hunt_tp_safe with storage helper:safe
