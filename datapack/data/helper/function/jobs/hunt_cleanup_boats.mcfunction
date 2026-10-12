# Remove boats bound to this helper (and nearby tagged orphans from older spawns).
tag @e[type=oak_boat,tag=helper.my_boat] remove helper.my_boat
execute as @e[type=oak_boat,tag=helper.boat] if score @s helper_id = @e[tag=helper.self,limit=1] helper_id run tag @s add helper.my_boat
# Also catch untagged/legacy boats left within 8 blocks
execute at @s as @e[type=oak_boat,tag=helper.boat,distance=..8] run tag @s add helper.my_boat
kill @e[type=oak_boat,tag=helper.my_boat]
