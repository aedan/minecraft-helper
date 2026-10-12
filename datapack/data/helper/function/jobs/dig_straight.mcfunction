# Dig a 2-tall tunnel straight ahead for helper_dig_left blocks.
# Facing is set when the job starts (owner look direction).
# Store mode: sweep nearby drops into the chest before ending the job.
# Dig counter only decreases when a solid block is broken — walking through
# already-open tunnel does not burn the quota.
execute unless score @s helper_dig_left matches 1.. if score @s helper_q1 matches 1 if entity @e[type=item,distance=..8,limit=1] run function helper:jobs/dig_deposit
execute unless score @s helper_dig_left matches 1.. if score @s helper_q1 matches 1 if entity @e[type=item,distance=..8,limit=1] run return 0
execute unless score @s helper_dig_left matches 1.. if score @s helper_q1 matches 1 run function helper:jobs/dig_deposit
execute unless score @s helper_dig_left matches 1.. run scoreboard players set @s helper_q1 0
execute unless score @s helper_dig_left matches 1.. run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Done digging.","color":"green"}]
execute unless score @s helper_dig_left matches 1.. run function helper:jobs/clear_work
execute unless score @s helper_dig_left matches 1.. run function helper:jobs/done
execute unless score @s helper_dig_left matches 1.. run return 0

execute store result score #hy helper_config run data get entity @s Pos[1]
execute if score #hy helper_config matches ..-63 run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Stopped — too close to the void.","color":"yellow"}]
execute if score #hy helper_config matches ..-63 run function helper:jobs/clear_work
execute if score #hy helper_config matches ..-63 run function helper:jobs/done
execute if score #hy helper_config matches ..-63 run return 0

execute at @s if block ^ ^ ^1 minecraft:bedrock run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Stopped — hit bedrock.","color":"yellow"}]
execute at @s if block ^ ^ ^1 minecraft:bedrock run function helper:jobs/clear_work
execute at @s if block ^ ^ ^1 minecraft:bedrock run function helper:jobs/done
execute at @s if block ^ ^ ^1 minecraft:bedrock run return 0

# Feet inside bedrock/stone: pop out. Never keep mining from inside a solid.
execute at @s run function helper:move/mark_feet_solid
execute if score #feet_solid helper_config matches 1 at @s run function helper:move/eject_solid
execute at @s run function helper:move/mark_feet_solid
execute if score #feet_solid helper_config matches 1 run tellraw @a[tag=helper.my_owner,limit=1] [{"text":"[Helper] ","color":"aqua"},{"text":"Stopped — I was inside a solid block.","color":"yellow"}]
execute if score #feet_solid helper_config matches 1 run function helper:jobs/clear_work
execute if score #feet_solid helper_config matches 1 run function helper:jobs/done
execute if score #feet_solid helper_config matches 1 run return 0

# Track whether this tick breaks anything (quota = mined columns, not air steps)
scoreboard players set #broke helper_config 0
execute at @s unless block ^ ^ ^1 #helper:passable unless block ^ ^ ^1 minecraft:bedrock unless block ^ ^ ^1 minecraft:barrier unless block ^ ^ ^1 minecraft:command_block run scoreboard players set #broke helper_config 1
execute at @s unless block ^ ^1 ^1 #helper:passable unless block ^ ^1 ^1 minecraft:bedrock unless block ^ ^1 ^1 minecraft:barrier unless block ^ ^1 ^1 minecraft:command_block run scoreboard players set #broke helper_config 1

# Break feet and head blocks ahead (skip indestructible)
execute at @s unless block ^ ^ ^1 #helper:passable unless block ^ ^ ^1 minecraft:bedrock unless block ^ ^ ^1 minecraft:barrier unless block ^ ^ ^1 minecraft:command_block run setblock ^ ^ ^1 air destroy
execute at @s unless block ^ ^1 ^1 #helper:passable unless block ^ ^1 ^1 minecraft:bedrock unless block ^ ^1 ^1 minecraft:barrier unless block ^ ^1 ^1 minecraft:command_block run setblock ^ ^1 ^1 air destroy

# Count only real breaks
execute if score #broke helper_config matches 1 run scoreboard players remove @s helper_dig_left 1

# Step forward when clear (through old tunnel or freshly broken column)
execute at @s if block ^ ^ ^1 #helper:passable if block ^ ^1 ^1 #helper:passable run tp @s ^ ^ ^1

# Vacuum nearby drops so the tunnel stays clean
# Store mode inserts drops into the work chest. Otherwise vacuum onto the helper.
execute if score @s helper_q1 matches 1 run function helper:jobs/dig_deposit
execute unless score @s helper_q1 matches 1 as @e[type=item,distance=..3] run tp @s @e[tag=helper.self,limit=1]
