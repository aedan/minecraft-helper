# Maze avoidance: stop searching passages; climb toward open sky / surface then re-aim.
# Does not dig horizontal tunnels. Clears upward body corridor then steps up.


# Clear 3-tall column upward and step up repeatedly (one step per call)
execute at @s unless block ~ ~2 ~ minecraft:bedrock unless block ~ ~2 ~ minecraft:barrier unless block ~ ~2 ~ #helper:passable run setblock ~ ~2 ~ air destroy
execute at @s unless block ~ ~3 ~ minecraft:bedrock unless block ~ ~3 ~ minecraft:barrier unless block ~ ~3 ~ #helper:passable run setblock ~ ~3 ~ air destroy
execute at @s if block ~ ~1 ~ #helper:passable if block ~ ~2 ~ #helper:passable run tp @s ~ ~1 ~

# If sky/open above (passable several blocks), reset stuck and resume overland
execute at @s if block ~ ~2 ~ #helper:passable if block ~ ~4 ~ #helper:passable if block ~ ~6 ~ #helper:passable run scoreboard players set @s helper_hunt_stuck 0

function helper:jobs/hunt_unstuck
