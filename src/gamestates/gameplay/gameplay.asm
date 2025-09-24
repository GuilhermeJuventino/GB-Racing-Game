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

    ld de, PlayerSprite
    ld hl, $8000
    ld bc, PlayerSpriteEnd - PlayerSprite
    call Memcpy


    ; Loading sprite to Shadow OAM
    ld hl, wShadowOAM

    ld a, 128 + 16 ; Object Y position
    ld [hli], a
    ld a, 16 + 46 ; Object X position
    ld [hli], a
    ld a, 0 ; Object attributes
    ld [hli], a
    ld [hli], a


    ; Turning LCD on
    ld a, LCDC_ENABLE | LCDC_BG_ON | LCDC_OBJ_ON | LCDC_OBJ_16
    ld [rLCDC], a

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
