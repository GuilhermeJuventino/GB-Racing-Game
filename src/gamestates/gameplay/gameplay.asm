INCLUDE "defines.inc"

SECTION "Gameplay", ROM0


InitGameplay::
    ; Copying Title Screen data to VRAM
    ld de, RaceTrackTiles
    ld hl, $9000
    ld bc, RaceTrackTilesEnd - RaceTrackTiles
    call Memcpy

    ld de, RaceTrackMap
    ld hl, $9800
    ld bc, RaceTrackMapEnd - RaceTrackMap
    call Memcpy

    ; Turning LCD on
    ld a, LCDC_ENABLE | LCDC_BG_ON | LCDC_OBJ_ON
    ld [rLCDC], a

    ret


UpdateGameplay::
    ld a, [rLY]
    cp 144
    jp nc, UpdateGameplay

    call WaitVBlank

    jp UpdateGameplay


SECTION "Racing Track Graphics", ROM0

RaceTrackTiles: INCBIN "assets/gameplay/backgrounds/background.2bpp"
RaceTrackTilesEnd:

RaceTrackMap: INCBIN "assets/gameplay/backgrounds/background.tilemap"
RaceTrackMapEnd:

