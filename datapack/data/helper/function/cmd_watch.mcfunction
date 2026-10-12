tag @s add helper.cmd
function helper:util/run_on_helper {fn:"helper:internal/set_watch"}
execute if score #found helper_config matches 1 run tellraw @s [{"text":"[Helper] ","color":"aqua"},{"text":"Mode: ","color":"green"},{"text":"Watch Back","color":"yellow"},{"text":" — following and protecting you.","color":"gray"}]
tag @s remove helper.cmd
