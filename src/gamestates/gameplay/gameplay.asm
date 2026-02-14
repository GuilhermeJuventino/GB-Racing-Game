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
    
    ; Reset Background Scroll position
    xor a
    ld [hSCX], a
    ld [hSCY], a

    call InitPlayer
    call InitEnemies

    ret


UpdateGameplay::
    ld a, [rLY]
    cp 144
    jp nc, UpdateGameplay
    
    call WaitVBlank

    call ClearShadowOAM

    ; Check if start button was pressed
    ldh a, [hPressedKeys]
    and PAD_START
    jp z, .exitTitleScreenEnd

    .exitTitleScreen:
        ld a, 0
        ld [wCurrentGameState], a
        ret
    .exitTitleScreenEnd:
    
    ; Scrolling the Background vertically
    ld a, [hSCY]
    sub 2
    ld [hSCY], a

    call UpdatePlayer
    call UpdateEnemies

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

