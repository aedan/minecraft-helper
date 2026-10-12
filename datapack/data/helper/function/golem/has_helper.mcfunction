# Sets helper.has_helper on the checking player if they already own one.
tag @s remove helper.has_helper
execute as @e[tag=helper.active] if score @s helper_id = @a[tag=helper.summoner,limit=1] helper_id run tag @a[tag=helper.summoner,limit=1] add helper.has_helper
