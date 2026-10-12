# Positioned at a container block. Args: {dx,dy,dz} offset from origin #org_ox/oy/oz.
# Appends {x,y,z,half,facing,items} to storage helper:api org.chests (up to #org_max).
# half: 0 single/barrel, 1 chest type=left, 2 type=right. facing: 0 n 1 e 2 s 3 w 4 other.
execute if score #org_n helper_config >= #org_max helper_config run return 0
execute if data block ~ ~ ~ LootTable run return 0
data modify storage helper:api org.entry set value {items:[],half:0,facing:4}
$scoreboard players set #org_x helper_config $(dx)
$scoreboard players set #org_y helper_config $(dy)
$scoreboard players set #org_z helper_config $(dz)
scoreboard players operation #org_x helper_config += #org_ox helper_config
scoreboard players operation #org_y helper_config += #org_oy helper_config
scoreboard players operation #org_z helper_config += #org_oz helper_config
execute store result storage helper:api org.entry.x int 1 run scoreboard players get #org_x helper_config
execute store result storage helper:api org.entry.y int 1 run scoreboard players get #org_y helper_config
execute store result storage helper:api org.entry.z int 1 run scoreboard players get #org_z helper_config
data modify storage helper:api org.entry.items set from block ~ ~ ~ Items
execute if block ~ ~ ~ #helper:double_chests[type=left] run data modify storage helper:api org.entry.half set value 1
execute if block ~ ~ ~ #helper:double_chests[type=right] run data modify storage helper:api org.entry.half set value 2
execute if block ~ ~ ~ #helper:double_chests[facing=north] run data modify storage helper:api org.entry.facing set value 0
execute if block ~ ~ ~ #helper:double_chests[facing=east] run data modify storage helper:api org.entry.facing set value 1
execute if block ~ ~ ~ #helper:double_chests[facing=south] run data modify storage helper:api org.entry.facing set value 2
execute if block ~ ~ ~ #helper:double_chests[facing=west] run data modify storage helper:api org.entry.facing set value 3
data modify storage helper:api org.chests append from storage helper:api org.entry
scoreboard players add #org_n helper_config 1
