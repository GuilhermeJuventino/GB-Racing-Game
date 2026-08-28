INCLUDE "defines.inc"

SECTION "SRAM", ROM0

; Checks if a valid save file is present
; return a: 0 if valid, 1 if invalid
ValidateChecksum::
    ld hl, rChecksumBytes
    ld de, sChecksum
    xor a
    ld c, a ; loop counter
    
.loop
    ld a, [de]
    ld b, a
    ld a, [hl]
    
    cp a, b
    jp nz, .checksumFailed

    inc hl
    inc de

    inc c
    ld a, c
    cp a, 13
    jp nz, .loop

.cheksumSuccessful
    ld a, 0

    ret

.checksumFailed
    ld a, 1

    ret


; Checks if current score has surpassed high score
; return a: 1 if a new high score was set, otherwise, return 0
CompareScores::
    ld de, sHiScore
    ld hl, wScore
    ld c, sHiScoreEnd - sHiScore

.loop
    ld a, [de]
    ld b, a
    ld a, [hl]

    cp a, b
    jp c, .scoreSmaller
    jp nz, .scoreBigger

    inc hl
    inc de
    dec c
    jr nz, .loop

.scoreSmaller
    xor a, a

    ret

.scoreBigger
    ld a, 1
    
    ret


SECTION "Checksum Data", ROM0


; Bytes to be written and checked for validating save files ($FF marks the end of the checksum)
rChecksumBytes:: db $43, $48, $41, $54, $55, $42, $41, $43, $4F, $4D, $45, $43, $55
rChecksumBytesEnd::


SECTION "Save Variables", SRAM


sChecksum:: ds 13
sChecksumEnd::

sHiScore:: ds 6
sHiScoreEnd::
