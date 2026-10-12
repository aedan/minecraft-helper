# As the owner, at the owner. Lightweight shared memory (updated every helper tick
# and owner tick). Scores live on the owner:
#   helper_tunnel — dig-face yaw of the 2-tall corridor they are standing in, if any.
#                  Kept until a newer corridor overwrites it (unset means "no memory").
# Tunnel axis is the direction into the SOLID dig face (short side), not back down
# the open tunnel and not into bedrock. See memory/tunnel_axis.
# Only refresh the tunnel axis while standing in a 2-tall passable corridor.
execute if block ~ ~ ~ #helper:passable if block ~ ~1 ~ #helper:passable run function helper:memory/tunnel_axis
