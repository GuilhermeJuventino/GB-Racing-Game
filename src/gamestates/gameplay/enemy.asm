INCLUDE "defines.inc"

struct Enemy
    words 1, y
    words 1, x
    bytes 1, metaspriteLeft
    bytes 1, metaspriteRight
    bytes 1, active
end_struct


SECTION "Enemy", ROM0


; Initializes graphics and variables related to enemies
InitEnemies::
    ld de, EnemySprite
    ld hl, $8040
    ld bc, EnemySpriteEnd - EnemySprite
    call LCDMemcpy
    
    ld a, 85
    ld [wXPos], a

    xor a
    ld [wEnemyIndex], a ; Index for loop
 
    ld de, wEnemies0

    .initLoop:
        call InitEnemy
        
        ld a, [wEnemyIndex]
        inc a
        ld [wEnemyIndex], a
        cp 4
        jp c, .initLoop
    .initLoopEnd:

    ret


; Initialize entry in wEnemies array
; param de: Index pointer of enemy array
; retunr de: Pointer to the next entry in the array
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
    xor a
    ld [hli], a
    
    
    ; Incrementing wEnemies pointer stored in DE to point to the next entry in the array
    ld hl, sizeof_Enemy
    add hl, de

    ld d, h
    ld e, l

    ret


; Loads enemy sprites into Shadow OAM
; param hl: pointer to Shadow OAM area designated to enemies
SetEnemySprite: 
    ld de, wEnemies0
    xor a
    ld [wEnemyIndex], a ; Index for loop

    .setSpriteLoop:
        ; Left Metasprite
        push hl
        ld h, d
        ld l, e

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy Y pos
        
        push hl
        ld h, d
        ld l, e

        ; X Pos Offset
        inc hl

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy X pos
        
        push hl
        ld h, d
        ld l, e

        ; Left Metasprite Offset
        inc hl
        inc hl

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy Left Metasprite

        xor a
        ld [hli], a ; Enemy Sprite Attributes

        ; Right Metasprite
        push hl
        ld h, d
        ld l, e

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy Y Pos
        
        push hl
        ld h, d
        ld l, e
        
        ; X Pos Offset
        inc hl

        ld a, [hl]
        add a, 8
        pop hl
        ld [hli], a ; Enemy X pos

        push hl
        ld h, d
        ld l, e

        ; Right Metasrptie Offset
        inc hl
        inc hl
        inc hl

        ld a, [hl]
        pop hl
        ld [hli], a ; Enemy Right Metasprite

        xor a
        ld [hli], a ; Enemy Sprite Attributes
        
        ; Incrementing wEnemies pointer stored in DE to point to the next entry in the array
        push hl
        ld hl, sizeof_Enemy
        add hl, de
        ld d, h
        ld e, l
        pop hl
        
        ; Incrementing Loop Index
        ld a, [wEnemyIndex]
        inc a
        ld [wEnemyIndex], a
        
        cp 4
        jp c, .setSpriteLoop
    .setSpriteLoopEnd:

    ret


; Update enemy sprites in the Shadow OAM
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
