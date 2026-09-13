# Storage area system: designate and organize a storage zone
# Storage area is a 16x16 block zone at the base

# Check if storage area is set
execute unless score #storage_set helper_config matches 1 run tellraw @a[limit=1] [{"text":"[Helper] ","color":"yellow"},{"text":"No storage area set. Use /helper set_storage first.","color":"gray"}]

# If storage area is set, organize it
execute if score #storage_set helper_config matches 1 run function helper:storage/organize_area
