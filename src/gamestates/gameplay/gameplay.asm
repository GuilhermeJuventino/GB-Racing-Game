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

    ld de, PlayerSprite
    ld hl, $8000
    ld bc, PlayerSpriteEnd - PlayerSprite
    call LCDMemcpy


    ; Loading sprite to Shadow OAM
    ld hl, wShadowOAM

    ld a, 128 + 16 ; Object Y position
    ld [hli], a
    ld a, 16 + 46 ; Object X position
    ld [hli], a
    ld a, 0 ; Object attributes
    ld [hli], a
    ld [hli], a

    ret


UpdateGameplay::
    ld a, [rLY]
    cp 144
    jp nc, UpdateGameplay

    call WaitVBlank

    ; Start OAM DMA transfer
    ld a, HIGH(wShadowOAM)
    ldh [hOAMHigh], a

    jp UpdateGameplay


SECTION "Racing Track Graphics", ROM0

RaceTrackTiles: INCBIN "assets/gameplay/backgrounds/background.2bpp"
RaceTrackTilesEnd:

RaceTrackMap: INCBIN "assets/gameplay/backgrounds/background.tilemap"
RaceTrackMapEnd:

PlayerSprite: INCBIN "assets/gameplay/sprites/player.2bpp"
PlayerSpriteEnd:
