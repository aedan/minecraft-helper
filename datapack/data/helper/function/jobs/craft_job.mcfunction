# Job 10: walk to owner (no long-range hunt rules), give crafted item from storage helper:craft.
tag @a[tag=helper.my_owner,limit=1] add helper.craft_owner

# Approach owner on foot / short follow (teleport_to_owner OK for deliver-to-owner)
execute unless entity @a[tag=helper.craft_owner,distance=..3,limit=1] if entity @a[tag=helper.craft_owner,limit=1] run function helper:follow/keep_up
execute unless entity @a[tag=helper.craft_owner,distance=..3,limit=1] run tag @a[tag=helper.craft_owner] remove helper.craft_owner
execute unless entity @a[tag=helper.my_owner,distance=..3,limit=1] run return 0

# In range: give item via macro
execute as @a[tag=helper.my_owner,limit=1] run function helper:jobs/craft_give with storage helper:craft
tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Here you go.","color":"green"}]
tag @a[tag=helper.craft_owner] remove helper.craft_owner
function helper:jobs/clear_work
function helper:jobs/done
