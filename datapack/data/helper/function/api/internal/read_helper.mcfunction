# As one of the caller's loaded helpers (see internal/begin).
scoreboard players set #api_loaded helper_config 1
scoreboard players operation #api_job helper_config = @s helper_job
execute if score @s helper_stay matches 1 run scoreboard players set #api_stay helper_config 1
tag @s add helper.api_me
