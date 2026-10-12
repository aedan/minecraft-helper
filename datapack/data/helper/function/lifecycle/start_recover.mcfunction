# Begin forceload recovery using last-known helper coords (per-player) and base.
# Does not teleport unless the owner also has tag helper.recall_tp (set by cmd_here).
scoreboard players set @s helper_recall 1
function helper:lifecycle/forceload_known
