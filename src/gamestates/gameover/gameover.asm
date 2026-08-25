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

    jp UpdateTitleScreen

