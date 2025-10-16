INCLUDE "defines.inc"

SECTION "Player", ROM0

struct Player
    words 1, y
    words 1, x
    bytes 1, metaspriteLeft
    bytes 1, metaspriteRight
end_struct


InitPlayer::
    dstruct Player, PlayerCar, .y=128, .x=16, .metaspriteLeft=0, .metaspriteRight=2

    ret


SECTION "PlayerAssets", ROM0

;PlayerSprite: INCBIN "assets/gameplay/sprites/player.2bpp"
;PlayerSpriteEnd:


SECTION "PlayerVariables", WRAM0
