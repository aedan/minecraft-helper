# Private order inbox for helper-brain.
# MC 26.x does NOT log /msg /tell /w to latest.log — self-whisper is invisible to Tom.
# Usage (op): /function helper:w {m:"Tom, dig 400"}
#            /function helper:msg {m:"Tom, dig 400"}
# Or dialog: /trigger tom   (or /trigger helper_cmd set 9)
$data modify storage helper:inbox msg set value "$(m)"
data modify storage helper:inbox pending set value 1b
tag @s add helper.inbox_pending
tellraw @s [{"text":"[","color":"dark_gray"},{"text":"Tom","color":"aqua"},{"text":"] ","color":"dark_gray"},{"text":"Private order received — on it.","color":"white"}]
