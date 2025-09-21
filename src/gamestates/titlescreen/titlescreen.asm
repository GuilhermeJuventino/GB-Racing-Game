INCLUDE "defines.inc"

SECTION "Title Screen", ROM0


InitTitleScreen::
    ; Copying Title Screen data to VRAM
    ld de, TitleScreenTiles
    ld hl, $9000
    ld bc, TitleScreenTilesEnd - TitleScreenTiles
    call Memcpy

    ld de, TitleScreenMap
    ld hl, $9800
    ld bc, TitleScreenMapEnd - TitleScreenMap
    call Memcpy

    ; Turning LCD on
    ld a, LCDC_ENABLE | LCDC_BG_ON | LCDC_OBJ_ON
    ld [rLCDC], a

    ret


UpdateTitleScreen::
    ld a, [rLY]
    cp 144
    jp nc, UpdateTitleScreen

    call WaitVBlank

    jp UpdateTitleScreen


SECTION "Title Screen Graphics", ROM0

TitleScreenTiles: INCBIN "assets/titlescreen/backgrounds/background.2bpp"
TitleScreenTilesEnd:

TitleScreenMap: INCBIN "assets/titlescreen/backgrounds/background.tilemap"
TitleScreenMapEnd:

