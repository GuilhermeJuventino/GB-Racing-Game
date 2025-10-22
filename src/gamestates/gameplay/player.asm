INCLUDE "defines.inc"

struct Player
    words 1, y
    words 1, x
    bytes 1, metaspriteLeft
    bytes 1, metaspriteRight
end_struct


SECTION "Player", ROM0

InitPlayer::
    ld de, PlayerSprite
    ld hl, $8000
    ld bc, PlayerSpriteEnd - PlayerSprite
    call LCDMemcpy

    ld hl, wPlayer_y
    ld a, 135
    ld [hl], a

    ld hl, wPlayer_x
    ld a, 85
    ld [hl], a

    ld hl, wPlayer_metaspriteLeft
    ld a, 0
    ld [hl], a

    ld hl, wPlayer_metaspriteRight
    ld a, 2
    ld [hl], a

    ; Loading sprite to Shadow OAM

    ret

SetPlayerSprite: 
    ; Left Metasprite
    ld de, wPlayer_y
    ld a, [de]
    ld [hli], a

    ld de, wPlayer_x
    ld a, [de]
    ld [hli], a

    ld de, wPlayer_metaspriteLeft
    ld a, [de]
    ld [hli], a

    ld a, 0
    ld [hli], a

    ; Right Metasprite
    ld de, wPlayer_y
    ld a, [de]
    ld [hli], a

    ld de, wPlayer_x
    ld a, [de]
    add a, 8
    ld [hli], a

    ld de, wPlayer_metaspriteRight
    ld a, [de]
    ld [hli], a

    ld a, 0
    ld [hli], a

    ret

; Must be called every frame
UpdatePlayer::
    call MovePlayer

    ld hl, wShadowOAM
    call SetPlayerSprite

    ret


MovePlayer:
    call CheckPlayerInput

    ret


CheckPlayerInput:
    ; Checking player input
.checkKeyLeft
    ld a, [hHeldKeys]
    and a, PAD_LEFT
    jp z, .checkKeyRight

.moveLeft
    ld a, [wPlayer_x]
    dec a
    ld [wPlayer_x], a

    ret

.checkKeyRight
    ld a, [hHeldKeys]
    and a, PAD_RIGHT
    ret z

.moveRight
    ld a, [wPlayer_x]
    inc a
    ld [wPlayer_x], a

    ret


SECTION "PlayerAssets", ROM0

PlayerSprite: INCBIN "assets/gameplay/sprites/player.2bpp"
PlayerSpriteEnd:


SECTION "PlayerVariables", WRAM0
dstruct Player, wPlayer
