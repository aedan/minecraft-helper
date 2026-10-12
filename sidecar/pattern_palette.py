"""Shared definition of the tunnel-pattern palette (datapack generator + sidecar decoder).

A pattern is a stack of slices taken behind the helper, relative to its facing:
  lateral x = -2..2 (positive = the helper's LEFT), height y = -1..2 (-1 = floor,
  0 = feet, 1 = head, 2 = ceiling), slice 0 = the block row right behind the helper.
Cell index inside a slice: (y + 1) * WIDTH + (x + 2).
Directional states (rail shapes, wall-torch facing) are stored RELATIVE to the facing
(F forward, B back, L left, R right), so a pattern stamps correctly in any direction.
The datapack generator (tools/datapack_gen.py) emits classify/put functions from this
table; changing it changes PALETTE_VERSION, which the sidecar checks before decoding.
"""
from __future__ import annotations

import hashlib

WIDTH = 5
HEIGHT = 4
LATERAL = range(-2, 3)
LEVELS = range(-1, 3)
MAX_DEPTH = 16  # slices read behind the helper
MAX_LENGTH = 8  # longest repeating segment
FILLER = "minecraft:cobblestone"  # used to fill missing floor/wall blocks

DIRS = ["south", "west", "north", "east"]  # facing index = round(yaw / 90) mod 4
VEC = {0: (0, 1), 1: (-1, 0), 2: (0, -1), 3: (1, 0)}
_REL = {"F": 0, "R": 1, "B": 2, "L": 3}


def rel_dir(facing: int, rel: str) -> int:
    return (facing + _REL[rel]) % 4


def cell_index(x: int, y: int) -> int:
    return (y + 1) * WIDTH + (x + 2)


def cell_pos(index: int) -> tuple[int, int]:
    return index % WIDTH - 2, index // WIDTH - 1


AIR, SOLID, KEEP = 0, 1, 2
_STRAIGHT = ["along", "across", "asc_F", "asc_B", "asc_L", "asc_R"]
_CURVES = ["F_L", "F_R", "B_L", "B_R"]
# (block, relative state); codes are list positions + 3
ENTRIES: list[tuple[str, str]] = (
    [("minecraft:rail", s) for s in _STRAIGHT + _CURVES]
    + [("minecraft:powered_rail", s) for s in _STRAIGHT]
    + [("minecraft:detector_rail", s) for s in _STRAIGHT]
    + [("minecraft:activator_rail", s) for s in _STRAIGHT]
    + [("minecraft:torch", ""), ("minecraft:redstone_torch", "")]
    + [("minecraft:wall_torch", r) for r in "FBLR"]
    + [("minecraft:redstone_wall_torch", r) for r in "FBLR"]
)
FIRST_CODE = 3
CODES = {FIRST_CODE + i: e for i, e in enumerate(ENTRIES)}
NAMES = {AIR: "air", SOLID: "solid", KEEP: "keep"}
PALETTE_VERSION = int(hashlib.sha1(repr((WIDTH, HEIGHT, ENTRIES, FILLER)).encode()).hexdigest()[:6], 16)
REL_WORDS = {"F": "forward", "B": "back", "L": "left", "R": "right", "along": "along the tunnel",
             "across": "across the tunnel"}


def is_rail(code: int) -> bool:
    return code in CODES and CODES[code][0].endswith("rail")


def is_torch(code: int) -> bool:
    return code in CODES and "torch" in CODES[code][0]


def abs_state(code: int, facing: int) -> str:
    """Absolute block state for a palette code when facing `facing`."""
    block, rel = CODES[code]
    if block.endswith("rail"):
        if rel == "along":
            shape = "north_south" if facing in (0, 2) else "east_west"
        elif rel == "across":
            shape = "east_west" if facing in (0, 2) else "north_south"
        elif rel.startswith("asc_"):
            shape = "ascending_" + DIRS[rel_dir(facing, rel[4])]
        else:
            a, b = (DIRS[rel_dir(facing, r)] for r in rel.split("_"))
            ns, ew = (a, b) if a in ("north", "south") else (b, a)
            shape = f"{ns}_{ew}"
        return f"{block}[shape={shape}]"
    if block.endswith("wall_torch"):
        return f"{block}[facing={DIRS[rel_dir(facing, rel)]}]"
    return block


def describe(code: int) -> str:
    if code in NAMES:
        return NAMES[code]
    block, rel = CODES[code]
    name = block.split(":", 1)[1]
    if not rel:
        return name
    if block.endswith("rail"):
        if rel.startswith("asc_"):
            return f"{name} ascending {REL_WORDS[rel[4]]}"
        if "_" in rel:
            a, b = rel.split("_")
            return f"{name} curve {REL_WORDS[a]}-{REL_WORDS[b]}"
        return f"{name} {REL_WORDS[rel]}"
    return f"{name} facing {REL_WORDS[rel]}"
