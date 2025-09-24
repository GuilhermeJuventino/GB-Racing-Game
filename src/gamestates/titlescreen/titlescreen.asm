INCLUDE "defines.inc"

SECTION "Title Screen", ROM0


InitTitleScreen::
    ; Copying Title Screen data to VRAM
    ld de, TitleScreenTiles
    ld hl, $9000
    ld bc, TitleScreenTilesEnd - TitleScreenTiles
    call LCDMemcpy

    ld de, TitleScreenMap
    ld hl, $9800
    ld bc, TitleScreenMapEnd - TitleScreenMap
    call LCDMemcpy

    ret


UpdateTitleScreen::
    ld a, [rLY]
    cp 144
    jp nc, UpdateTitleScreen

    call WaitVBlank
    
    ; Check if start button was pressed
    ldh a, [hPressedKeys]
    and PAD_START
    jp z, .exitTitleScreenEnd

    .exitTitleScreen:
        ld a, 1
        ld [wCurrentGameState], a
        ret
    .exitTitleScreenEnd:

    jp UpdateTitleScreen


SECTION "Title Screen Graphics", ROM0

TitleScreenTiles: INCBIN "assets/titlescreen/backgrounds/background.2bpp"
TitleScreenTilesEnd:

TitleScreenMap: INCBIN "assets/titlescreen/backgrounds/background.tilemap"
TitleScreenMapEnd:

