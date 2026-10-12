# Macro: {name:"Oak"} — nameplate is only the name.
$data modify entity @s CustomName set value {text:"$(name)"}
$data merge entity @s {CustomNameVisible:1b,hide_description:1b,description:{text:""},profile:{name:"$(name)"}}
