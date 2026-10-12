# Fill sandwiched gaps on learned lanes at the helper's current column. No torches, no bridging.
execute unless score @s helper_gkind matches 1..7 run scoreboard players set @s helper_gkind 2
execute if score @s helper_gkind matches 1 positioned ^-1 ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 3 positioned ^-1 ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 5 positioned ^-1 ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 7 positioned ^-1 ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 2 positioned ^ ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 3 positioned ^ ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 6 positioned ^ ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 7 positioned ^ ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 4 positioned ^1 ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 5 positioned ^1 ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 6 positioned ^1 ^ ^ run function helper:jobs/repair_rails_cell
execute if score @s helper_gkind matches 7 positioned ^1 ^ ^ run function helper:jobs/repair_rails_cell
