INCLUDE "defines.inc"

struct Player
    words 1, y
    words 1, x
    bytes 1, metaspriteLeft
    bytes 1, metaspriteRight
end_struct


SECTION "Player", ROM0


; Initializes graphics and variables related to the player
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

    ret


; Loads player sprites into Shadow OAM
; param hl: Pointer to Shadow OAM area designated to the player
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
    ld [hli], a ; Player Sprite Attributes

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
    ld [hli], a ; Player Sprite Attributes

    ret


; Updates the player's position and graphics
; Must be called every frame
UpdatePlayer::
    call MovePlayer

    ld hl, wShadowOAM
    call SetPlayerSprite

    ret


MovePlayer:
    call CheckPlayerInput
    call CheckPlayerTileCollision
    call CheckPlayerSpriteCollision

    ret


; Checks controller input and moves the player accordingly
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


; Checks if player is colliding with the left or right boundary tiles of the racing track
CheckPlayerTileCollision:
    ; Checking left boundary tile
    ld a, [wPlayer_x]
    sub 8 ; negative 8 px offset
    ld b, a
    ld a, [wPlayer_y]
    ld c, a
    call GetTileByPixel

    ld a, [hl]
    cp a, $04
    jp nz, .collideWithLeftBoundaryEnd

    .collideWithLeftBoundary
        ld a, [wPlayer_x]
        inc a
        ld [wPlayer_x], a

        ret
    .collideWithLeftBoundaryEnd

    ; Checking right boundary tile
    ld a, [wPlayer_x]
    add 7 ; positive 7 px offset
    ld b, a
    ld a, [wPlayer_y]
    ld c, a
    call GetTileByPixel

    ld a, [hl]
    cp a, $08
    jp nz, .collideWithRightBoundaryEnd

    .collideWithRightBoundary
        ld a, [wPlayer_x]
        dec a
        ld [wPlayer_x], a
    .collideWithRightBoundaryEnd

    ret


; Loops trough the enemy sprites array, and check if the player has
; collided with any of the enemies
CheckPlayerSpriteCollision:
    xor a
    ld [wEnemyIndex], a

    ld de, wEnemies0

.loop
    call CheckPlayerVsEnemyCollision

    ld a, 0
    cp a, c
    jp nz, .collisionFound
    

    ld hl, sizeof_wEnemies0
    add hl, de
    ld d, h
    ld e, l

    ld a, [wEnemyIndex]
    inc a
    ld [wEnemyIndex], a

    cp 4
    jp c, .loop

    jp .collisionFoundEnd

.collisionFound
    call KillPlayer

    ret

.collisionFoundEnd

    ret


; Checks if player sprite has collided with an enemy sprite
; param de: Pointer to enemy struct
; return c: 0 if no collision, 1 if collision is detected
CheckPlayerVsEnemyCollision:
    def WIDTH equ 16
    def HEIGHT equ 16

    ; CASE 1: player.x < enemy.x + width
    inc de ; Enemy.x

    ld a, [de]
    ld b, a
    ld a, [WIDTH]
    add a, b

    ld b, a
    ld a, [wPlayer_x]
    
    cp a, b
    jp nc, .noCollision

    ; CASE 2: player.x + width > enemy.x
    ld a, [de]
    ld b, a
    ld a, [wPlayer_x]

    ld c, a
    ld a, [WIDTH]
    add a, c

    cp a, b
    jp c, .noCollision

    ; CASE 3: player.y < enemy.y + height
    dec de; Enemy.y

    ld a, [de]
    ld b, a
    ld a, [HEIGHT]
    add a, b

    ld b, a
    ld a, [wPlayer_y]
    
    cp a, b
    jp nc, .noCollision
 
    ; CASE 4: player.y + height > enemy.y
    ld a, [de]
    ld b, a
    ld a, [wPlayer_y]

    ld c, a
    ld a, [HEIGHT]
    add a, c

    cp a, b
    jp c, .noCollision

    ; Collision Found
    jp .noCollisionEnd

.noCollision
    xor a
    ld c, a

    ret

.noCollisionEnd
    ld a, 1
    ld c, a

    ret


KillPlayer:    
    ld a, 1
    ld [wShouldExitGameplayState], a

    ret


SECTION "PlayerAssets", ROM0


PlayerSprite: INCBIN "assets/gameplay/sprites/player.2bpp"
PlayerSpriteEnd:


SECTION "PlayerVariables", WRAM0


dstruct Player, wPlayer
