# Legacy entry point (fight / close approach). Does NOT dig horizontal walls.
# Routes to surface-first overland; dig-down only when target is beneath + close.

function helper:jobs/hunt_open_door
function helper:jobs/hunt_overland

# Dig down last resort when close and target below
execute if entity @a[tag=helper.hunt_target,distance=..32,limit=1] run function helper:jobs/hunt_dig_down
function helper:jobs/hunt_unstuck
