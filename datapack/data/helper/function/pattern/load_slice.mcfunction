# Slice for step #pk: index d = (-(#pat_base + #pk) - 1) mod #pat_L, cells -> #pc0..#pc19.
scoreboard players operation #pd helper_config = #pat_base helper_config
scoreboard players operation #pd helper_config += #pk helper_config
scoreboard players set #pat_m1 helper_config -1
scoreboard players operation #pd helper_config *= #pat_m1 helper_config
scoreboard players remove #pd helper_config 1
scoreboard players operation #pd helper_config %= #pat_L helper_config
execute if score #pd helper_config matches ..-1 run scoreboard players operation #pd helper_config += #pat_L helper_config
execute store result storage helper:tmp pslice.d int 1 run scoreboard players get #pd helper_config
function helper:pattern/load_slice_at with storage helper:tmp pslice
function helper:pattern/load_cells
