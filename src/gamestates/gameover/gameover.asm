INCLUDE "defines.inc"

SECTION "Game Over Screen", ROM0


InitGameOver::
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
    ld hl, wScore
    ld de, $9800 + 12 + 9 * 32
    call PrintScore

    ; Printing high score text
    ld de, $9800 + 2 + 12 * 32
    ld hl, rHiScoreText
    call PrintText
    
    ; Printing high score
    ld hl, wScore
    ld de, $9800 + 12 + 12 * 32
    call PrintScore

    ; Reset Background Scroll position
    xor a
    ld [hSCX], a
    ld [hSCY], a
    
    ; Turning LCD back on
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_OFF | LCDC_OBJ_OFF | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

    ret


UpdateGameOver::
    ld a, [rLY]
    cp 144
    jp nc, UpdateGameOver

    call WaitVBlank
    
    call ClearShadowOAM

    ; Check if start button was pressed
    ldh a, [hPressedKeys]
    and PAD_START
    jp z, .exitGameOverEnd

    .exitGameOver:
        ld a, 1 ; Exiting to gameplay state
        ld [wCurrentGameState], a
        ret
    .exitGameOverEnd:

    ; Start OAM DMA transfer
    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a

    jp UpdateGameOver

