# A rail/torch where the pattern is open: break it (drops the item).
setblock ~ ~ ~ minecraft:air destroy
scoreboard players add #pat_removed helper_config 1
