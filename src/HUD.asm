INCLUDE "defines.inc"

SECTION "HUD", ROM0


; TODO: Write a character map for the custom font

; TODO: Write functions to print font at a specified X and Y Coordinates


SECTION "HUD Graphics", ROM0


FontTiles:: INCBIN "assets/HUD/Font/font.2bpp"
FontTilesEnd::
