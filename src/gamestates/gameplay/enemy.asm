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
    ld [hli], a
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
    def MODULO_X equ $38

.roll:
    call rand
    and MODULO_X - 1
    cp RANGE_X :: jr nc, .roll
    add MIN_X
    
    ld [wXPos], a

    ret


SetSpawnTimer:
    def MIN_DELAY equ 32
    def MAX_DELAY equ 120

    def RANGE_DELAY equ MAX_DELAY - MIN_DELAY
    def MODULO_DELAY equ 88

.roll:
    call rand
    and MODULO_DELAY - 1
    cp RANGE_DELAY :: jr nc, .roll
    add MIN_DELAY

    ld [wSpawnDelay], a

    ret


; Loops trough the wEnemies array until it finds a non active enemy
; And spawns said enemy with a randomized X position if the spawn timer has reached zero
EnemySpawner:
    ld a, [wSpawnDelay]
    cp a, 1
    ret nc ; Checking the spawn delay timer has reached zero, and skipping the function if it's greater than zero

    ld hl, wEnemies0
    xor a
    ld [wEnemyIndex], a
    
.loop:
    ld de, 4
    add hl, de ; wEnemies[i]. active
    
    ld a, [hl]
    cp a, 1
    jp nz, .skipIndexEnd ; Checking if current enemy is not active

.skipIndex:
    ; Moving to next entry in wEnemies
    dec hl
    dec hl
    dec hl
    dec hl ; Back to wEnemies[i].active

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
    dec hl ; Back to wEnemies[i].active

    ; Randomizing current Eenmy's X Position and moving on to the next entry
    push hl

    call RollEnemyPosition
    
    pop hl

    inc hl
    ld a, [wXPos]
    ld [hl], a
    call SetSpawnTimer
    
ret


; Loops through the wEnemies array and updates their Y coordinates accordingly
MoveEnemies:
    ld hl, wEnemies0
    xor a
    ld [wEnemyIndex], a ; Loop index

.loop:
    ld bc, sizeof_Enemy

    ld de, 4
    add hl, de ; wEnemies[i].active

    ld a, [hl]
    cp 0
    jp nz, .skipIndexEnd ; Checking if wEnemies0[i].active is not zero

.skipIndex:
    ; Moving to next entry in wEneies
    dec hl
    dec hl
    dec hl
    dec hl ; Back to wEnemies[i].y

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
    dec hl
    dec hl
    dec hl
    dec hl ; Back to wEnemies[i].y

    ld a, [hl]
    cp $A2
    jp c, .resetPositionEnd ; Check if current Enemy's Y position is beneath the screen limit

.resetPosition:
    xor a
    ld [hl], a
    
    inc hl
    inc hl
    inc hl
    inc hl ; wEnemies[i].active
    
    ld [hl], a

    dec hl
    dec hl
    dec hl
    dec hl ; Back to wEnemies[i].y
    
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
