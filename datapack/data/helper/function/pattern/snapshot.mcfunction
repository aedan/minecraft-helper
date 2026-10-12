# As/at the helper. Reads 16 slices behind it (5 wide x 4 high, relative to its facing),
# finds the repeating segment, and on success replaces storage helper:api pattern:
#   {facing, width, height, length, verified, origin:{x,y,z}, palette, cells:[[20 codes]...]}
# Input #pat_req_len: 0 = detect the period, 1..8 = use this length.
# Output #pat_len: 0 if no pattern (the old pattern is kept).
function helper:pattern/facing
execute if score #pat_dir helper_config matches 0 align xyz run function helper:pattern/read_f0
execute if score #pat_dir helper_config matches 1 align xyz run function helper:pattern/read_f1
execute if score #pat_dir helper_config matches 2 align xyz run function helper:pattern/read_f2
execute if score #pat_dir helper_config matches 3 align xyz run function helper:pattern/read_f3
scoreboard players set #pat_len helper_config 0
scoreboard players set #pat_verified helper_config 0
execute if score #pat_req_len helper_config matches 1..8 run scoreboard players operation #pat_len helper_config = #pat_req_len helper_config
execute if score #pat_req_len helper_config matches 1..8 run function helper:pattern/verify_two
execute if score #pat_req_len helper_config matches 0 run function helper:pattern/detect
execute if score #pat_req_len helper_config matches 0 if score #pat_len helper_config matches 1.. run scoreboard players set #pat_verified helper_config 1
execute if score #pat_len helper_config matches 0 run return 0
data modify storage helper:api pattern set value {width:5,height:4,cells:[]}
execute store result storage helper:api pattern.facing int 1 run scoreboard players get #pat_dir helper_config
execute store result storage helper:api pattern.length int 1 run scoreboard players get #pat_len helper_config
execute store result storage helper:api pattern.verified byte 1 run scoreboard players get #pat_verified helper_config
execute store result storage helper:api pattern.origin.x int 1 run data get entity @s Pos[0]
execute store result storage helper:api pattern.origin.y int 1 run data get entity @s Pos[1]
execute store result storage helper:api pattern.origin.z int 1 run data get entity @s Pos[2]
function helper:pattern/commit
data remove storage helper:tmp pscan
