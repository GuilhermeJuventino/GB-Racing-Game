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
 
    .initLoop:
        ld de, wEnemies0
        ;inc de
        ld a, 0
        ;ld hl, wEnemyIndex
        ld [hl], a
        call InitEnemy

        ld a, [wEnemyIndex]
        inc de
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
    add hl, de
    
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

    ret


SetEnemySprite: 
    ld de, wEnemies0

    ld a, 0
    ld [wEnemyIndex], a

    .setSpriteLoop:
        ; Left Metasprite
        ld a, [de]
        ld [hli], a ; Enemy Y pos
        inc de

        ld a, [de]
        ld [hli], a ; Enemy X pos
        inc de

        ld a, [de]
        ld [hli], a ; Enemy Left Metasprite

        ld a, 0
        ld [hli], a ; Enemy Sprite Attributes

        ; Decrementing DE twice, so that we can reuse the current index's x and y coordinates for next metasprite
        dec de
        dec de

        ; Right Metasprite
        ld a, [de]
        ld [hli], a ; Enemy Y pos
        inc de

        ld a, [de]
        add a, 8
        ld [hli], a ; Enemy X pos

        ; Incrementing DE twice, so that we can now use the right metasprite
        inc de
        inc de

        ld a, [de]
        ld [hli], a ; Enemy Right Metasprite

        ld a, 0
        ld [hli], a ; Enemy Sprite Attributes
        
        inc de
        inc de

        ld a, [wEnemyIndex]
        inc a
        ld [wEnemyIndex], a
        
        cp 3
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
