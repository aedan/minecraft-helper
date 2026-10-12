# Args: {b:"<block state>"}. Place a rail/torch unless the right one is already here;
# a different rail/torch here is broken first (drops the item).
$execute if block ~ ~ ~ $(b) run return 0
$setblock ~ ~ ~ $(b) destroy
scoreboard players add #pat_placed helper_config 1
