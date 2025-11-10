INCLUDE "defines.inc"

struct Enemy
    words 1, y
    words 1, x
    bytes 1, metaspriteLeft
    bytes 1, metaspriteRight
    bytes 1, active
end_struct


SECTION "Enemy", ROM0


InitEnemies::
    ld de, EnemySprite
    ld hl, $8040
    ld bc, EnemySpriteEnd - EnemySprite
    call LCDMemcpy
    
    ld a, 85
    ld [wXPos], a

    xor a
    ld [wEnemyIndex], a
 
    ld de, wEnemies0

    .initLoop:
        call InitEnemy

        ld a, [wEnemyIndex]
        inc a
        ld [wEnemyIndex], a
        cp 4
        jp c, .initLoop
    .initLoopEnd:

    ld a, 85
    ld [wXPos], a

    xor a
    ld [wEnemyIndex], a

    ret


; de - index pointer of enemy array
InitEnemy:
    ld h, d
    ld l, e
    
    ; wEnemies[i] Y pos
    ld a, 135
    ld [hli], a

    ; wEnemies[i] X pos
    ld a, [wXPos]
    ld [hli], a
    add a, 20
    ld [wXPos], a
     
    ; wEnemies[i] metaspriteLeft
    ld a, 4
    ld [hli], a

    ; wEnemies[i] metaspriteRight
    ld a, 6
    ld [hli], a
    
    ; wEnemies[i] active
    ld a, 0
    ld [hli], a
    
    ld h, d
    ld l, e

    ld de, sizeof_Enemy
    add hl, de

    ld d, h
    ld e, l

    ret


SetEnemySprite: 
    ld de, wEnemies0
    xor a
    ld [wEnemyIndex], a

    .setSpriteLoop:
        ; Left Metasprite
        push hl
        ld h, d
        ld l, e
        ld bc, Enemy_y
        add hl, bc

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy Y pos
        
        push hl
        ld h, d
        ld l, e
        ld bc, Enemy_x
        add hl, bc

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy X pos
        
        push hl
        ld h, d
        ld l, e
        ld bc, Enemy_metaspriteLeft
        add hl, bc

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy Left Metasprite

        ld a, 0
        ld [hli], a ; Enemy Sprite Attributes

        ; Right Metasprite
        push hl
        ld h, d
        ld l, e
        ld bc, Enemy_y
        add hl, bc

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy Y pos
        
        push hl
        ld h, d
        ld l, e
        ld bc, Enemy_x
        add hl, bc

        ld a, [hl]
        add a, 8
        pop hl
        ld [hli], a ; Enemy X pos

        push hl
        ld h, d
        ld l, e
        ld bc, Enemy_metaspriteRight
        add hl, bc

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy Right Metasprite

        ld a, 0
        ld [hli], a ; Enemy Sprite Attributes
        
        push hl
        ld hl, sizeof_Enemy
        add hl, de
        ld d, h
        ld e, l
        pop hl

        ld a, [wEnemyIndex]
        inc a
        ld [wEnemyIndex], a
        
        cp 4
        jp c, .setSpriteLoop
    .setSpriteLoopEnd:

    ret


UpdateEnemies::
    ld hl, wShadowOAM + 8
    call SetEnemySprite

    ret


SECTION "EnemyAssets", ROM0


EnemySprite: INCBIN "assets/gameplay/sprites/enemycar.2bpp"
EnemySpriteEnd:


SECTION "EnemyVariables", WRAM0

wXPos: db
wEnemyIndex: db
dstructs 4, Enemy, wEnemies
