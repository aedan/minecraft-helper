# Step back: helper is too close (<1 block), push it to a fixed 2-block offset
# Uses the guard marker (absolute) so it doesn't orbit your crosshair.
execute as @a[limit=1] at @s run function helper:combat/guard_position
