INCLUDE "defines.inc"

SECTION "Gameplay", ROM0


InitGameplay::
    

.loop
    ldh a, [rLY]
    cp 144
    jr c, .loop

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
    ld hl, rScoreText
    call PrintText
    
    ; Reset Background Scroll position
    xor a
    ldh [hSCX], a
    ldh [hSCY], a
    
    ; Setting Window layer's position
    ld a, 7
    ldh [rWX], a

    ld a, 135
    ldh [rWY], a
    
    ; Turning LCD, Window and OBJ Layer back on
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_WIN_ON | LCDC_WIN_9C00 | LCDC_OBJ_ON | LCDC_OBJ_16
    ldh [hLCDC], a
    ldh [rLCDC], a
    
    xor a
    ; Initializing state flag variables
    ld [wShouldExitGameplayState], a
    
    ldh [wScore], a
    ldh [wScore + 1], a
    ldh [wScore + 2], a
    ldh [wScore + 3], a
    ldh [wScore + 4], a
    ldh [wScore + 5], a

    ld a, 8
    ldh [wScoreTick], a
    ldh [wScoreTickTime], a

    ld a, 3
    ldh [wScrollSpeed], a

    xor a
    ld [randstate], a
    ld [randstate + 1], a
    ld [randstate + 2], a
    ld [randstate + 3], a

    ldh [wIsPaused], a

    ldh [wLevel], a

    call InitPlayer
    call InitEnemies
    
    call EnableSTATInterrupts

    ret


UpdateGameplay::
    ldh a, [rLY]
    cp 144
    jr nc, UpdateGameplay
    
    call WaitVBlank
    call rand

    ; Check if game should be paused
    ldh a, [hPressedKeys]
    and PAD_START
    jr z, .pauseGameEnd

.pauseGame

    ldh a, [wIsPaused]
    cp 0
    jp z, .pause

    xor a
    ldh [wIsPaused], a
    jr .pauseGameEnd

.pause

    ld a, 1
    ldh [wIsPaused], a

.pauseGameEnd
    
    ; Check if game is paused. If so, go back to the start of the loop
    ldh a, [wIsPaused]
    cp 1
    jr z, UpdateGameplay

    ; if not inside VBlank, continue without printing the score.
    ld a, [rLY]
    cp 144
    jr c, .printScoreEnd

.printScore

    ld hl, wScore
    ld de, $9C00 + 10
    call PrintScore

.printScoreEnd

    call ClearShadowOAM

    ld a, [wShouldExitGameplayState]
    cp 1
    jr nz, .exitGameplayEnd

    .exitGameplay:
        ld a, 2 ; Exiting to game over state
        ld [wCurrentGameState], a
        ret
    .exitGameplayEnd:
    
    ; Scrolling the Background vertically
    ldh a, [wScrollSpeed]
    ld b, a
    ldh a, [hSCY]
    sub a, b
    ldh [hSCY], a

    call UpdatePlayer
    call UpdateEnemies
    call AdjustDifficulty

    ld hl, wScore + 5
    ld de, wScoreTick
    call IncrementScore

    ; Start OAM DMA transfer
    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a

    ldh a, [rDIV]
    ld [randstate], a

    jp UpdateGameplay


AdjustDifficulty:
    ; 100 pts
    ldh a, [wScore + 3]

    cp 1
    jr nz, .level2End

.level2

    ldh a, [wLevel]
    cp 2
    ret nc

    ld a, 6
    ld [wMaxEnemiesToSpawn], a

    ld a, 2
    ldh [wLevel], a

    ret

.level2End
    
    ; 200 pts
    ldh a, [wScore + 3]

    cp 2
    jr nz, .level3End

.level3

    ldh a, [wLevel]
    cp 3
    ret nc

    ld a, 7
    ld [wMaxEnemiesToSpawn], a

    ld a, 3
    ldh [wLevel], a
    
    ret

.level3End
    
    ; 300 pts
    ldh a, [wScore + 3]

    cp 3
    jr nz, .level4End

.level4

    ldh a, [wLevel]
    cp 4
    ret nc

    ld a, 8
    ld [wMaxEnemiesToSpawn], a

    ld a, 4
    ldh [wLevel], a

    ret

.level4End
    ; 500 pts
    ldh a, [wScore + 3]

    cp 5
    jr nz, .level5End

.level5

    ldh a, [wLevel]
    cp 5
    ret nc

    ld a, 12
    ld [wMaxEnemiesToSpawn], a

    ld a, 5
    ldh [wLevel], a

.level5End

    ret


SECTION "Gameplay Variables", WRAM0


; WRAM copy of the Racing Track Tile Map for collision detection
wRaceTrackMap:: db

; Variable to track whether or not the game should exit the gameplay state
wShouldExitGameplayState:: db


SECTION "Gameplay HRAM", HRAM


; Player Score
wScore:: ds 6

wScoreTick: db

wScoreTickTime:: db

wIsPaused: db

wScrollSpeed: db

wLevel:: db


SECTION "Racing Track Graphics", ROM0


RaceTrackTiles: INCBIN "assets/gameplay/backgrounds/background.2bpp"
RaceTrackTilesEnd:

RaceTrackMap: INCBIN "assets/gameplay/backgrounds/background.tilemap"
RaceTrackMapEnd:

