INCLUDE "defines.inc"

SECTION "Gameplay", ROM0


InitGameplay::
    ; Copying Title Screen data to VRAM
    ld de, RaceTrackTiles
    ld hl, $9000
    ld bc, RaceTrackTilesEnd - RaceTrackTiles
    call LCDMemcpy

    ld de, RaceTrackMap
    ld hl, $9800
    ld bc, RaceTrackMapEnd - RaceTrackMap
    call LCDMemcpy

    ld de, RaceTrackMap
    ld hl, wRaceTrackMap
    ld bc, RaceTrackMapEnd - RaceTrackMap
    call Memcpy

    call InitPlayer

    ret


UpdateGameplay::
    ld a, [rLY]
    cp 144
    jp nc, UpdateGameplay
    
    call WaitVBlank

    call ClearShadowOAM

    call UpdatePlayer

    ; Start OAM DMA transfer
    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a

    jp UpdateGameplay


SECTION "Gameplay Variables", WRAM0

; WRAM copy of the Racing Track Tile Map for collision detection
wRaceTrackMap:: db


SECTION "Racing Track Graphics", ROM0

RaceTrackTiles: INCBIN "assets/gameplay/backgrounds/background.2bpp"
RaceTrackTilesEnd:

RaceTrackMap: INCBIN "assets/gameplay/backgrounds/background.tilemap"
RaceTrackMapEnd:

