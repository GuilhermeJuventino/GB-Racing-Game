INCLUDE "defines.inc"

SECTION "Game Over Screen", ROM0


InitGameOver::
    

.loop
    ldh a, [rLY]
    cp 144
    jr c, .loop

    ; Turning LCD and OBJ Layer off to load title screen assets
    ld a, LCDC_OFF | LCDC_BG_OFF | LCDC_WIN_OFF | LCDC_OBJ_OFF | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

    ; Filling the entire Background Layer Tilemap with blank tiles
    ld a, $80
    ld hl, $9800
    ld bc, $9BFF - $9800
    call LCDMemset

    ; Printing game over text
    ld de, $9800 + 5 + 5 * 32
    ld hl, rGameOverText
    call PrintText

    ; Printing score text
    ld de, $9800 + 2 + 9 * 32
    ld hl, rScoreText
    call PrintText
    
    ; Printing score
    ld hl, hScore
    ld de, $9800 + 12 + 9 * 32
    call PrintScore

    ; Printing high score text
    ld de, $9800 + 2 + 12 * 32
    ld hl, rHiScoreText
    call PrintText

    ld a, RAMG_SRAM_ENABLE
    ld [rRAMG], a

    ;
    call CompareScores
    cp a, 1
    jr nz, .newHighScoreEnd

.newHighScore 
    ld de, rChecksumBytes
    ld hl, sChecksum
    ld bc, sChecksumEnd - sChecksum
    call Memcpy

    ld de, hScore
    ld hl, sHiScore
    ld bc, sHiScoreEnd - sHiScore
    call Memcpy

    ; Printing new record text
    ld de, $9800 + 5 + 15 * 32
    ld hl, rNewRecordText
    call PrintText

.newHighScoreEnd
    
    ; Printing high score
    ld hl, sHiScore
    ld de, $9800 + 12 + 12 * 32
    call PrintScore

    ld a, RAMG_SRAM_DISABLE
    ld [rRAMG], a

    ; Reset Background Scroll position
    xor a
    ldh [hSCX], a
    ldh [hSCY], a
    
    ; Turning LCD back on
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_OFF | LCDC_OBJ_OFF | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

    ret


UpdateGameOver::
    ldh a, [rLY]
    cp 144
    jr nc, UpdateGameOver

    call WaitVBlank
    
    call ClearShadowOAM

    ; Check if we should start the game again
    ldh a, [hPressedKeys]
    and PAD_START | PAD_A | PAD_B
    jr z, .exitGameOverEnd

    .exitGameOver:
        ld a, 1 ; Exiting to gameplay state
        ld [wCurrentGameState], a
        ret
    .exitGameOverEnd:

    ; Start OAM DMA transfer
    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a

    ; save context
    push bc
    push de
    push hl

    ; check if sound should be updated
    ldh a, [hSoundUpdate]
    and a
    jr z, .no_init
    call hUGE_dosound

.no_init
    ; restore context
    pop hl
    pop de
    pop bc

    jr UpdateGameOver

