# Post-respawn messaging + honor come-here by warping to owner when requested.
# Re-apply bound name onto the live helper (summon hardcodes "Helper").
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run function helper:lifecycle/apply_bound_name
execute if entity @s[tag=helper.recall_tp] run function helper:lifecycle/recall_success
execute unless entity @s[tag=helper.recall_tp] run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Respawned.","color":"green"}]
tag @s remove helper.cmd
tag @s remove helper.summoner
tag @s remove helper.recall_tp
