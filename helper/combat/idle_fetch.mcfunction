# Fetch mode: actively search for the target resource

# Check if target resource is set
execute if score #fetch_target helper_config matches 1.. run function helper:combat/search_resource
execute unless score #fetch_target helper_config matches 1.. run function helper:combat/idle_default
