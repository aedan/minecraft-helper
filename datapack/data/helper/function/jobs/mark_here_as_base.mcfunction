# As helper, at helper. Reuse owner-tagged base placement by pretending to be cmd.
tag @a[tag=helper.my_owner,limit=1] add helper.cmd
execute at @s run function helper:combat/place_base_marker
tag @a[tag=helper.cmd] remove helper.cmd
