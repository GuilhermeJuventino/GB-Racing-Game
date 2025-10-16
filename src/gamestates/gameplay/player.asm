INCLUDE "defines.inc"

struct Player
    words 1, y
    words 1, x
    bytes 1, metaspriteLeft
    bytes 1, metaspriteRight
end_struct


SECTION "Player", ROM0

InitPlayer::
    ;dstruct Player, PlayerCar, .y=128, .x=16, .metaspriteLeft=0, .metaspriteRight=2
    ld de, wPlayer_y
    ld a, 12
    ld [de], a

    ret


SECTION "PlayerAssets", ROM0

;PlayerSprite: INCBIN "assets/gameplay/sprites/player.2bpp"
;PlayerSpriteEnd:


SECTION "PlayerVariables", WRAM0
dstruct Player, wPlayer
