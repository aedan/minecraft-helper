# Alias for helper:w — private order inbox (MC 26.x does not log /msg).
# Usage: /function helper:msg {m:"Tom, dig 400"}
# Shorter path: /trigger tom  (opens dialog)
$data modify storage helper:inbox msg set value "$(m)"
data modify storage helper:inbox pending set value 1b
tag @s add helper.inbox_pending
tellraw @s [{"text":"[","color":"dark_gray"},{"text":"Tom","color":"aqua"},{"text":"] ","color":"dark_gray"},{"text":"Private order received — on it.","color":"white"}]
