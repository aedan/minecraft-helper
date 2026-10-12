# Teleport helper to base using stored integer coords
# Uses the persistent base marker.

execute if entity @e[type=marker,tag=helper.base,limit=1] run tp @e[tag=helper.active,limit=1] @e[type=marker,tag=helper.base,limit=1]
