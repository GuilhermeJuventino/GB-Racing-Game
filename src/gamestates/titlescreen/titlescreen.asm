INCLUDE "defines.inc"

SECTION "Title Screen", ROM0


InitTitleScreen::
    ; Turning LCD and OBJ Layer off to load title screen assets
    ld a, LCDC_OFF | LCDC_BG_OFF | LCDC_WIN_OFF | LCDC_OBJ_OFF | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

    ; Copying Title Screen data to VRAM
    ld de, TitleScreenTiles
    ld hl, $9000
    ld bc, TitleScreenTilesEnd - TitleScreenTiles
    call LCDMemcpy

    ld de, TitleScreenMap
    ld hl, $9800
    ld bc, TitleScreenMapEnd - TitleScreenMap
    call LCDMemcpy

    ; Reset Background Scroll position
    xor a
    ld [hSCX], a
    ld [hSCY], a
    
    ; Turning LCD back on
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_OFF | LCDC_OBJ_OFF | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a

    xor a
    ld [randstate], a
    ld [randstate + 1], a
    ld [randstate + 2], a
    ld [randstate + 3], a

    ret


UpdateTitleScreen::
    ld a, [rLY]
    cp 144
    jp nc, UpdateTitleScreen

    call WaitVBlank
    
    call ClearShadowOAM

    ; Check if start button was pressed
    ldh a, [hPressedKeys]
    and PAD_START
    jp z, .exitTitleScreenEnd

    .exitTitleScreen:
        ld a, 1
        ld [wCurrentGameState], a
        ret
    .exitTitleScreenEnd:

    ; Start OAM DMA transfer
    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a

    jp UpdateTitleScreen


SECTION "Title Screen Graphics", ROM0


TitleScreenTiles: INCBIN "assets/titlescreen/backgrounds/background.2bpp"
TitleScreenTilesEnd:

TitleScreenMap: INCBIN "assets/titlescreen/backgrounds/background.tilemap"
TitleScreenMapEnd:

