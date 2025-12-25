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
    
    ;ld a, 85
    ;ld [wXPos], a

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
    
    ld a, [wEnemies0]

    call SetSpawnTimer

    ret


; Initialize entry in wEnemies array
; param de: Index pointer of enemy array
; return de: Pointer to the next entry in the array
InitEnemy:
    ld h, d
    ld l, e
    
    ; wEnemies[i] Y pos
    xor a
    ld [hli], a

    ; wEnemies[i] X pos
    ;ld a, 0
    ld [hli], a
    ;add a, 20
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
        ld b, h
        ld c, l

        ld h, d
        ld l, e

        ld a, [hl]
        ld h, b
        ld l, c
        ld [hli], a ; Enemy Y pos
        
        ld b, h
        ld c, l

        ld h, d
        ld l, e

        ; X Pos Offset
        inc hl

        ld a, [hl]
        ld h, b
        ld l, c
        ld [hli], a ; Enemy X pos
        
        ld b, h
        ld c, l

        ld h, d
        ld l, e

        ; Left Metasprite Offset
        inc hl
        inc hl

        ld a, [hl]
        ld h, b
        ld l, c
        ld [hli], a ; Enemy Left Metasprite

        xor a
        ld [hli], a ; Enemy Sprite Attributes

        ; Right Metasprite
        ld b, h
        ld c, l

        ld h, d
        ld l, e

        ld a, [hl]
        ld h, b
        ld l, c
        ld [hli], a ; Enemy Y Pos
        
        ld b, h
        ld c, l

        ld h, d
        ld l, e
        
        ; X Pos Offset
        inc hl

        ld a, [hl]
        add a, 8
        ld h, b
        ld l, c
        ld [hli], a ; Enemy X pos
        
        ld b, h
        ld c, l

        ld h, d
        ld l, e

        ; Right Metasrptie Offset
        inc hl
        inc hl
        inc hl

        ld a, [hl]
        ld h, b
        ld l, c
        ld [hli], a ; Enemy Right Metasprite

        xor a
        ld [hli], a ; Enemy Sprite Attributes
        
        ; Incrementing wEnemies pointer stored in DE to point to the next entry in the array
        ld b, h
        ld c, l
        ld hl, sizeof_Enemy
        add hl, de
        ld d, h
        ld e, l

        ld h, b
        ld l, c
        
        ; Incrementing Loop Index
        ld a, [wEnemyIndex]
        inc a
        ld [wEnemyIndex], a
        
        cp 4
        jp c, .setSpriteLoop
    .setSpriteLoopEnd:
    
    xor a
    ld [wEnemyIndex], a

    ret


RollEnemyPosition:
    def MIN_X equ $38
    def MAX_X equ $70

    def RANGE_X equ MAX_X - MIN_X
    def MODULO_X equ $1C

.roll:
    call rand
    and MODULO_X - 1
    cp RANGE_X :: jr nc, .roll
    add MIN_X
    
    ld [wXPos], a

    ret


SetSpawnTimer:
    def MIN_DELAY equ 8
    def MAX_DELAY equ 16

    def RANGE_DELAY equ MAX_DELAY - MIN_DELAY
    def MODULO_DELAY equ 8

.roll:
    call rand
    and MODULO_DELAY - 1
    cp RANGE_DELAY :: jr nc, .roll
    add MIN_DELAY

    ld [wSpawnDelay], a

    ret


EnemySpawner:
    ld a, [wSpawnDelay]
    cp a, 1
    ret nc

    ld hl, wEnemies0
    xor a
    ld [wEnemyIndex], a
    
.loop:
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    
    ld a, [hl]
    cp a, 1
    jp nz, .skipIndexEnd

.skipIndex:
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl

    ld d, h
    ld e, l

    ld hl, sizeof_Enemy
    add hl, de

    ld a, [wEnemyIndex]
    inc a
    ld [wEnemyIndex], a

    cp 4
    jp c, .loop

    ret

.skipIndexEnd:
    ld a, 1
    ld [hl], a

    dec hl
    dec hl
    dec hl
    dec hl
    dec hl

    push hl

    call RollEnemyPosition
    
    pop hl

    inc hl
    ld a, [wXPos]
    ld [hl], a
    call SetSpawnTimer
    
ret


MoveEnemies:
    ld hl, wEnemies0
    xor a
    ld [wEnemyIndex], a ; Loop index

.loop:
    ld d, h
    ld e, l
    ld bc, sizeof_Enemy

    inc de
    inc de
    inc de
    inc de
    inc de

    ld a, [de]
    cp 0
    jp nz, .skipIndexEnd ; Checking if wEnemies0[i].active is not zero

.skipIndex:
    ; Moving to next entry in wEneies
    ld d, h
    ld e, l

    ld h, b
    ld l, c

    add hl, de
    ld a, [wEnemyIndex]
    inc a
    ld [wEnemyIndex], a
    
    cp 4
    jp c, .loop

    ret

.skipIndexEnd:
    ld a, [hl]
    cp $B2
    jp c, .resetPositionEnd

.resetPosition:
    xor a
    ld [hl], a
    
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    
    ld [hl], a

    dec hl
    dec hl
    dec hl
    dec hl
    dec hl

    ld d, h
    ld e, l

    ld h, b
    ld l, c

    add hl, de

    ld a, [wEnemyIndex]
    inc a
    ld [wEnemyIndex], a

    cp 4
    jp c, .loop

    ret

.resetPositionEnd:
    inc a
    ld [hl], a ; Incrementing wEnemies[i].y position

    ; Moving to next entry in wEnemies
    ld d, h
    ld e, l

    ld h, b
    ld l, c

    add hl, de

    ld a, [wEnemyIndex]
    inc a
    ld [wEnemyIndex], a

    cp 4
    jp c, .loop 

ret


; Update enemies' position and graphics
; Must be called every frame
UpdateEnemies::
    ld a, [wSpawnDelay]
    dec a
    ld [wSpawnDelay], a
    
    call MoveEnemies
    call EnemySpawner

    ld hl, wShadowOAM + 8
    call SetEnemySprite

    ret


SECTION "EnemyAssets", ROM0


EnemySprite: INCBIN "assets/gameplay/sprites/enemycar.2bpp"
EnemySpriteEnd:


SECTION "EnemyVariables", WRAM0

wXPos: db
wSpawnDelay: db
wEnemyIndex: db
dstructs 4, Enemy, wEnemies
