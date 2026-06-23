INCLUDE "defines.inc"

SECTION "Gameplay", ROM0


InitGameplay::
    ; Turning LCD, Window and OBJ Layer off to load gameplay assets
    ld a, LCDC_OFF | LCDC_BG_OFF | LCDC_WIN_OFF | LCDC_OBJ_OFF
    ldh [hLCDC], a
    ldh [rLCDC], a

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
    
    ; Filling the entire Window Layer Tilemap with blank tiles
    ld a, $80
    ld hl, $9C00
    ld bc, $9FFF - $9C00
    call LCDMemset

    ld de, $9C00 + 4
    ld hl, wScoreText
    call PrintText
    
    ; Reset Background Scroll position
    xor a
    ld [hSCX], a
    ld [hSCY], a
    
    ; Setting Window layer's position
    ld a, 7
    ld [rWX], a

    ld a, 135
    ld [rWY], a
    
    ; Turning LCD, Window and OBJ Layer back on
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_ON | LCDC_WIN_9C00 | LCDC_OBJ_ON | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a
    
    xor a
    ; Initializing state flag variables
    ld [wShouldExitGameplayState], a
    
    ld [wScore], a
    ld [wScore + 1], a
    ld [wScore + 2], a
    ld [wScore + 3], a
    ld [wScore + 4], a
    ld [wScore + 5], a

    ld a, 8
    ld [wScoreTick], a
    ld [wScoreTickTime], a

    call InitPlayer
    call InitEnemies
    
    call EnableSTATInterrupts

    ret


UpdateGameplay::
    ld a, [rLY]
    cp 144
    jp nc, UpdateGameplay
    
    call WaitVBlank

    ld hl, wScore
    ld de, $9C00 + 10
    call PrintScore

    call ClearShadowOAM

    ld a, [wShouldExitGameplayState]
    cp 1
    jp nz, .exitTitleScreenEnd

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

    ld hl, wScore + 5
    ld de, wScoreTick
    call IncrementScore

    ; Start OAM DMA transfer
    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a

    jp UpdateGameplay


SECTION "Gameplay Variables", WRAM0


; WRAM copy of the Racing Track Tile Map for collision detection
wRaceTrackMap:: db

; Variable to track whether or not the game should exit the gameplay state
wShouldExitGameplayState:: db

; Player Score
wScore:: ds 6

wHiScore:: ds 6

wScoreTick: db

wScoreTickTime:: db


SECTION "Racing Track Graphics", ROM0


RaceTrackTiles: INCBIN "assets/gameplay/backgrounds/background.2bpp"
RaceTrackTilesEnd:

RaceTrackMap: INCBIN "assets/gameplay/backgrounds/background.tilemap"
RaceTrackMapEnd:

