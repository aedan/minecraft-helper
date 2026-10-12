tag @s add helper.cmd
function helper:util/run_on_helper {fn:"helper:internal/set_stay"}
execute if score #found helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Mode: ","color":"green"},{"text":"Stay Home","color":"yellow"},{"text":" — patrolling your base.","color":"gray"}]
tag @s remove helper.cmd
