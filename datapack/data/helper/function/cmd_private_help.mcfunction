# Owner-only private-order UX.
# MC 26.x never logs /msg to latest.log — self-whisper cannot reach helper-brain.
tellraw @s [{"text":"\n[Helper] Private orders","color":"aqua","bold":true}]
tellraw @s [{"text":"Helper name is tom. Vanilla /msg /tell /w are NOT logged here — whispers never reach Tom.","color":"gray"}]
tellraw @s [{"text":"Easiest private path (others cannot read the order text):","color":"yellow"}]
tellraw @s [{"text":"[/trigger tom]","color":"light_purple","click_event":{"action":"run_command","command":"trigger tom"}},{"text":"  opens a private order form","color":"gray"}]
tellraw @s [{"text":"[Click to type]","color":"aqua","click_event":{"action":"suggest_command","command":"/function helper:w {m:\"Tom, \"}"}},{"text":" /function helper:w {m:\"Tom, dig 400\"}","color":"white"}]
tellraw @s [{"text":"  Same: /function helper:msg {m:\"Tom, …\"}","color":"dark_gray"}]
tellraw @s [{"text":"You get an owner-only ack immediately; Tom never goes silent.","color":"green"}]
tellraw @s [{"text":"Public still works: Tom, keep laying rails… (others can see that line).","color":"dark_gray"}]
