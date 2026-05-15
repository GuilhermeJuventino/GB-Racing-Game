INCLUDE "defines.inc"

SECTION "HUD", ROM0


; Text Character Map for displaying text
CHARMAP " ", $80
CHARMAP ".", $98
CHARMAP "-", $99
CHARMAP "a", $9A
CHARMAP "b", $9B
CHARMAP "c", $9C
CHARMAP "d", $9D
CHARMAP "e", $9E
CHARMAP "f", $9F
CHARMAP "g", $A0
CHARMAP "h", $A1
CHARMAP "i", $A2
CHARMAP "j", $A3
CHARMAP "k", $A4
CHARMAP "l", $A5
CHARMAP "m", $A6
CHARMAP "n", $A7
CHARMAP "o", $A8
CHARMAP "p", $A9
CHARMAP "q", $AA
CHARMAP "r", $AB
CHARMAP "s", $AC
CHARMAP "t", $AD
CHARMAP "u", $AE
CHARMAP "v", $AF
CHARMAP "w", $B0
CHARMAP "x", $B1
CHARMAP "y", $B2
CHARMAP "z", $B3


; Print a string/text to the specified tilemap at the specified coordinates
; param de: Tilemap. By default it will print at the start of the tilemap.
; If you desire to specify a X coordinate to print, you can do
; de = Tilemap + X.
; To specify both X and Y coordinates, do de = Tilemap + X + Y * 32 (32 being the height of the Tilemaps)
; param hl: String/text to print

PrintText::
.loop
    ld a, [hl]
    cp a, 255
    ret z

    ld [de], a
    inc de
    inc hl

    jp .loop


; Print the Score or High Score to the specified tilemap at the specified coordinates
; param hl: Score address (used as parameter so same function can be used to print either score or high score)
; param de: Tilemap. By default it will print at the start of the tilemap.
; If you desire to specify a X coordinate to print, you can do
; de = Tilemap + X.
; To specify both X and Y coordinates, do de = Tilemap + X + Y * 32 (32 being the height of the Tilemaps)

PrintScore::
    ld c, 6

.loop
    ld a, [hli]
    add $8A ; Numeric tiles start at $8A, so we add that to each byte's value
    ld [de], a

    ; Decrement loop counter
    dec c

    ; Return once all digits have been drawn
    ret z
    
    ; Increase which digit we are drawing to
    inc de

    jp .loop



SECTION "HUD Variables", WRAM0


SECTION "HUD Graphics", ROM0


FontTiles:: INCBIN "assets/HUD/Font/font.2bpp"
FontTilesEnd::

wScoreText:: db "score", 255
