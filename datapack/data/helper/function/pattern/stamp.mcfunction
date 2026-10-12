# As/at the helper. Repeats storage helper:api pattern forward #pat_n blocks from the
# helper, rotated to its current facing. The helper does not move.
#   pass 0: every slice must be loaded and have room for its open/rail/torch cells;
#           the first failing slice ends the stamp (stopped_at, reason)
#   pass 1: fill missing floor/wall cells (cobblestone), remove rails/torches where the
#           pattern is open
#   pass 2: place rails and torches (already-correct blocks are left alone)
# Blocks are placed directly, like the helper's other rail/torch jobs (no inventory).
# Phase: if the helper is on the snapshot line with the same facing, the pattern
# continues in step with the existing tunnel; otherwise it restarts at the helper.
function helper:pattern/facing
execute store result score #pat_f helper_config run data get storage helper:api pattern.facing
execute store result score #pat_L helper_config run data get storage helper:api pattern.length
scoreboard players set #pat_base helper_config 0
execute if score #pat_dir helper_config = #pat_f helper_config run function helper:pattern/phase
scoreboard players set #pat_rot helper_config 0
execute unless score #pat_dir helper_config = #pat_f helper_config run scoreboard players set #pat_rot helper_config 1
scoreboard players operation #pat_stop helper_config = #pat_n helper_config
scoreboard players set #pat_at helper_config 0
scoreboard players set #pat_placed helper_config 0
scoreboard players set #pat_removed helper_config 0
data modify storage helper:tmp stamp set value {reason:"done",code:"done",msg:"Done."}
execute align xyz run function helper:pattern/walk_all
