# As owner at owner, already known to be in a 2-tall passable cell.
# Probe N/S/E/W. The dug tunnel is the LONG open run. The dig face is the opposite
# direction: a short run that ends in diggable solid (not bedrock, not open air).
# #pick helper_config becomes that yaw, or stays -999 if we cannot see a face.
# Also stores it on helper_tunnel when found.
scoreboard players set #10 helper_config 10
scoreboard players set #pick helper_config -999
execute rotated 0 0 run function helper:memory/probe_dir
scoreboard players operation #open_s helper_config = #open helper_config
scoreboard players operation #face_s helper_config = #face helper_config
execute rotated 180 0 run function helper:memory/probe_dir
scoreboard players operation #open_n helper_config = #open helper_config
scoreboard players operation #face_n helper_config = #face helper_config
execute rotated 90 0 run function helper:memory/probe_dir
scoreboard players operation #open_w helper_config = #open helper_config
scoreboard players operation #face_w helper_config = #face helper_config
execute rotated -90 0 run function helper:memory/probe_dir
scoreboard players operation #open_e helper_config = #open helper_config
scoreboard players operation #face_e helper_config = #face helper_config

scoreboard players set #best helper_config -1
# score = open(opposite)*10 - open(this). Only diggable faces, and only if the
# opposite side is the longer opening (we are looking at the near wall).
execute if score #face_s helper_config matches 1 if score #open_n helper_config > #open_s helper_config run scoreboard players operation #cand helper_config = #open_n helper_config
execute if score #face_s helper_config matches 1 if score #open_n helper_config > #open_s helper_config run scoreboard players operation #cand helper_config *= #10 helper_config
execute if score #face_s helper_config matches 1 if score #open_n helper_config > #open_s helper_config run scoreboard players operation #cand helper_config -= #open_s helper_config
execute if score #face_s helper_config matches 1 if score #open_n helper_config > #open_s helper_config if score #cand helper_config > #best helper_config run scoreboard players operation #best helper_config = #cand helper_config
execute if score #face_s helper_config matches 1 if score #open_n helper_config > #open_s helper_config if score #cand helper_config = #best helper_config run scoreboard players set #pick helper_config 0

execute if score #face_n helper_config matches 1 if score #open_s helper_config > #open_n helper_config run scoreboard players operation #cand helper_config = #open_s helper_config
execute if score #face_n helper_config matches 1 if score #open_s helper_config > #open_n helper_config run scoreboard players operation #cand helper_config *= #10 helper_config
execute if score #face_n helper_config matches 1 if score #open_s helper_config > #open_n helper_config run scoreboard players operation #cand helper_config -= #open_n helper_config
execute if score #face_n helper_config matches 1 if score #open_s helper_config > #open_n helper_config if score #cand helper_config > #best helper_config run scoreboard players operation #best helper_config = #cand helper_config
execute if score #face_n helper_config matches 1 if score #open_s helper_config > #open_n helper_config if score #cand helper_config = #best helper_config run scoreboard players set #pick helper_config 180

execute if score #face_w helper_config matches 1 if score #open_e helper_config > #open_w helper_config run scoreboard players operation #cand helper_config = #open_e helper_config
execute if score #face_w helper_config matches 1 if score #open_e helper_config > #open_w helper_config run scoreboard players operation #cand helper_config *= #10 helper_config
execute if score #face_w helper_config matches 1 if score #open_e helper_config > #open_w helper_config run scoreboard players operation #cand helper_config -= #open_w helper_config
execute if score #face_w helper_config matches 1 if score #open_e helper_config > #open_w helper_config if score #cand helper_config > #best helper_config run scoreboard players operation #best helper_config = #cand helper_config
execute if score #face_w helper_config matches 1 if score #open_e helper_config > #open_w helper_config if score #cand helper_config = #best helper_config run scoreboard players set #pick helper_config 90

execute if score #face_e helper_config matches 1 if score #open_w helper_config > #open_e helper_config run scoreboard players operation #cand helper_config = #open_w helper_config
execute if score #face_e helper_config matches 1 if score #open_w helper_config > #open_e helper_config run scoreboard players operation #cand helper_config *= #10 helper_config
execute if score #face_e helper_config matches 1 if score #open_w helper_config > #open_e helper_config run scoreboard players operation #cand helper_config -= #open_e helper_config
execute if score #face_e helper_config matches 1 if score #open_w helper_config > #open_e helper_config if score #cand helper_config > #best helper_config run scoreboard players operation #best helper_config = #cand helper_config
execute if score #face_e helper_config matches 1 if score #open_w helper_config > #open_e helper_config if score #cand helper_config = #best helper_config run scoreboard players set #pick helper_config -90

execute if score #pick helper_config matches -180..180 run scoreboard players operation @s helper_tunnel = #pick helper_config
