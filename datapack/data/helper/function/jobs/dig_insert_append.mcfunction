scoreboard players set #slots helper_config 0
execute store result score #slots helper_config run data get block ~ ~ ~ Items
execute if score #slots helper_config matches 27.. run return 0
execute store result storage helper:digdrop in.Slot byte 1 run scoreboard players get #slots helper_config
execute store success score #ok helper_config run data modify block ~ ~ ~ Items append from storage helper:digdrop in
execute if score #ok helper_config matches 1 run scoreboard players set #ins helper_config 1
