# Macro: {x,y,z} last-known hunt target. Overland toward it — no warp onto victim.
$execute at @s facing $(x) $(y) $(z) run tp @s ~ ~ ~ ~ ~
function helper:jobs/hunt_open_door
execute at @s if block ^ ^ ^0.55 #helper:passable if block ^ ^1 ^0.55 #helper:passable run function helper:move/forward_fast
execute at @s unless block ^ ^ ^0.55 #helper:passable run function helper:jobs/hunt_overland
function helper:jobs/hunt_unstuck
