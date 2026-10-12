# Dual-side pattern: redstone torch on the center walkway between left/right rails.
execute if block ~ ~ ~ #helper:passable unless block ~ ~-1 ~ #helper:passable unless block ~ ~ ~ #minecraft:rails run setblock ~ ~ ~ minecraft:redstone_torch
