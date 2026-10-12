# Args: {reason, msg}. Pass 0 found slice #pk unusable: stamp only slices before it.
$data modify storage helper:tmp stamp set value {reason:"$(reason)",code:"$(reason)",msg:"$(msg)"}
scoreboard players operation #pat_at helper_config = #pk helper_config
scoreboard players operation #pat_stop helper_config = #pk helper_config
scoreboard players remove #pat_stop helper_config 1
