# As the owner. Origin = storage point if set, else the owner's base.
execute if score #storage_set helper_config matches 1 run scoreboard players operation #org_ox helper_config = #storage_x helper_config
execute if score #storage_set helper_config matches 1 run scoreboard players operation #org_oy helper_config = #storage_y helper_config
execute if score #storage_set helper_config matches 1 run scoreboard players operation #org_oz helper_config = #storage_z helper_config
execute unless score #storage_set helper_config matches 1 run scoreboard players operation #org_ox helper_config = @s helper_bx
execute unless score #storage_set helper_config matches 1 run scoreboard players operation #org_oy helper_config = @s helper_by
execute unless score #storage_set helper_config matches 1 run scoreboard players operation #org_oz helper_config = @s helper_bz
execute store result storage helper:api org.origin.x int 1 run scoreboard players get #org_ox helper_config
execute store result storage helper:api org.origin.y int 1 run scoreboard players get #org_oy helper_config
execute store result storage helper:api org.origin.z int 1 run scoreboard players get #org_oz helper_config
function helper:api/internal/org_scan_base_at with storage helper:api org.origin
