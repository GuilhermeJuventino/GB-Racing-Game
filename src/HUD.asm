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


; Increment the Score after the score tick timer reaches zero
; param hl: Socre + 5 (so that you start with the first digit from right to left)
; param de: The current score tick time

IncrementScore::
    ; Check if score tick timer has reached zero, if not, decrement timer and return
    ld a, [de]
    cp 0
    jp z, .tickEnd

.tick
    ; Decrement tick timer and return
    dec a
    ld [de], a

    ret

.tickEnd

    ld c, 0 ; Loop counter

.loop
    ld a, [hl] ; Current Digit
    add 1
    daa ; converting to Binary Coded Decimal
    ld [hl], a

    cp 10 ; Check if current digit is hasn't gone past zero
    jp c, .loopEnd ; if so, return

    inc c ; incrementing counter
    ld a, c

    cp 6
    jp nz, .capAt999999End ; Check if loop counter has not gone over the score bounds (return if so)
    

.capAt999999
    ld a, [hl]
    cp 9
    jp c, .loopEnd ; Checking if the final digit hasn't gone past 9

    ld a, 9
    ld [hl], a
    ld [hli], a
     
    ld [hl], a
    ld [hli], a

    ld [hl], a
    ld [hli], a

    ld [hl], a
    ld [hli], a

    ld [hl], a
    ld [hli], a

    ret

.capAt999999End

    ; If not at the final digit of the score, and current digit has gone past zero
    ld a, 0 

    ; Settung current digit to zero and moving on to the next digit
    ld [hl], a
    ld [hld], a
    
    jp .loop

.loopEnd
    ; Reset score tick timer and return
    ld a, [wScoreTickTime]
    ld [de], a

    ret


SECTION "HUD Variables", WRAM0


SECTION "HUD Graphics", ROM0


FontTiles:: INCBIN "assets/HUD/Font/font.2bpp"
FontTilesEnd::

wScoreText:: db "score", 255
