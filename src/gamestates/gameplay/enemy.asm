INCLUDE "defines.inc"

struct Enemy
    words 1, y
    words 1, x
    bytes 1, metaspriteLeft
    bytes 1, metaspriteRight
    bytes 1, active
end_struct


SECTION "Enemy", ROM0


InitEnemy::
    ld de, EnemySprite
    ld hl, $8040
    ld bc, EnemySpriteEnd - EnemySprite
    call LCDMemcpy

    ld hl, wEnemy_y
    ld a, 135
    ld [hl], a

    ld hl, wEnemy_x
    ld a, 95
    ld [hl], a

    ld hl, wEnemy_metaspriteLeft
    ld a, 4
    ld [hl], a

    ld hl, wEnemy_metaspriteRight
    ld a, 6
    ld [hl], a

    ld hl, wEnemy_active
    xor a
    ld [hl], a

    ret


SetEnemySprite: 
    ; Left Metasprite
    ld de, wEnemy_y
    ld a, [de]
    ld [hli], a

    ld de, wEnemy_x
    ld a, [de]
    ld [hli], a

    ld de, wEnemy_metaspriteLeft
    ld a, [de]
    ld [hli], a

    ld a, 0
    ld [hli], a

    ; Right Metasprite
    ld de, wEnemy_y
    ld a, [de]
    ld [hli], a

    ld de, wEnemy_x
    ld a, [de]
    add a, 8
    ld [hli], a

    ld de, wEnemy_metaspriteRight
    ld a, [de]
    ld [hli], a

    ld a, 0
    ld [hli], a

    ret


UpdateEnemies::
    ld hl, wShadowOAM + 8
    call SetEnemySprite

    ret


SECTION "EnemyAssets", ROM0


EnemySprite: INCBIN "assets/gameplay/sprites/enemycar.2bpp"
EnemySpriteEnd:


SECTION "EnemyVariables", WRAM0


dstruct Enemy, wEnemy
