$execute unless data block ~ ~ ~ Items[$(i)] run return 0
data modify storage helper:digdrop cmp set value ""
$data modify storage helper:digdrop cmp set from block ~ ~ ~ Items[$(i)].id
execute store success score #diff helper_config run data modify storage helper:digdrop cmp set from storage helper:digdrop in.id
execute if score #diff helper_config matches 1 run return 0
$execute store result score #cnt helper_config run data get block ~ ~ ~ Items[$(i)].count
execute if score #cnt helper_config matches 64.. run return 0
execute store result score #add helper_config run data get storage helper:digdrop in.count
scoreboard players operation #cnt helper_config += #add helper_config
execute if score #cnt helper_config matches 65.. run return 0
$execute store result block ~ ~ ~ Items[$(i)].count int 1 run scoreboard players get #cnt helper_config
scoreboard players set #ins helper_config 1
