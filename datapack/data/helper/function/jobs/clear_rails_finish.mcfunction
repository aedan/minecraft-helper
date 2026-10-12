# Owner-only completion ack; idle Tom. Also wipe bad period cache if we cleared anything.
execute if score @s helper_no_tree matches 1.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Cleared ","color":"green"},{"score":{"name":"@s","objective":"helper_no_tree"},"color":"yellow"},{"text":" bad rail/torch blocks. Check the tip, then tell me when the sample looks good before finishing the tunnel.","color":"green"}]
execute unless score @s helper_no_tree matches 1.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"No messed rails found ahead in range.","color":"green"}]
# Drop poisoned gt1=2 cache so next lay re-observes
execute if score @s helper_no_tree matches 1.. run data remove storage helper:rail_pattern ok
execute if score @s helper_no_tree matches 1.. run scoreboard players set @s helper_gt1 0
execute if score @s helper_no_tree matches 1.. run scoreboard players set @s helper_gt2 0
execute if score @s helper_no_tree matches 1.. run scoreboard players set @s helper_gt3 0
function helper:jobs/clear_work
function helper:jobs/done
