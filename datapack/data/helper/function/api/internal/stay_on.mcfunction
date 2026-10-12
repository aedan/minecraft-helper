# As a helper. Stay-at-base wins over protect-and-follow: drop work, stop following.
function helper:api/internal/cancel_work
scoreboard players set @s helper_stay 1
scoreboard players set @s helper_mode 1
