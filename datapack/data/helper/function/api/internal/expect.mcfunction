# Args: {job:<int>, what:"<text>"}. As the caller, after a legacy job starter ran.
# Starters can refuse (solid spot, bedrock, no target...) and only explain in chat, so
# success is judged by whether the helper actually took the expected job.
scoreboard players set #api_gotjob helper_config -1
execute as @e[tag=helper.api_me,limit=1] run scoreboard players operation #api_gotjob helper_config = @s helper_job
$execute unless score #api_gotjob helper_config matches $(job) run return run function helper:api/internal/fail {code:"refused",msg:"The helper could not start $(what) here. Check chat for the reason."}
$function helper:api/internal/ok {code:"started",msg:"Started $(what)."}
