# Look for nearby diamond ore; otherwise wander.

function helper:mine/scan_near
execute at @s run tp @s ~ ~ ~ ~8 ~
execute at @s run function helper:move/forward
