INCLUDE "defines.inc"

SECTION "utils", ROM0

; Clears ShadowOAM (object Attribute Memory)
ClearShadowOAM::
    ld a, 0
    ld b, 160
    ld hl, wShadowOAM
.clearShadowOAMLoop
    ld [hli], a
    dec b
    jp nz, .clearShadowOAMLoop
    
    ret

; Convert a pixel position to a tile address
; hl = Tilemap (WRAM copy) + X + Y  * 32
; param b: X
; param c: Y
; return hl: tile address
GetTileByPixel::
    ; First we must divide by 8 to convert a pixel to tile position.
    ; After that, we must multiply the Y coordinate by 32.
    ; Those operations cancel out, therefore, we only need to mask the Y value.
    ld a, c
    and a, %11111000
    ld l, a
    ld h, 0
    ; We now have the position * 8 in hl.
    add hl, hl ; hl * 16
    add hl, hl ; hl * 32
    ; Convert X position to an offset.
    ld a, b
    srl a ; a / 2
    srl a ; a / 4
    srl a ; a / 8
    ; Adding the two offsets together.
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Add the offset to the tilemap's base address, and then we're done.
    ld bc, wRaceTrackMap
    add hl, bc

    ret
