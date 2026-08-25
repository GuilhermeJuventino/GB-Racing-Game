INCLUDE "defines.inc"

SECTION "Game State Machine", ROM0


InitGameStateMachine::
    ld a, 0
    ld [wCurrentGameState], a
    
    ; Copying game font into VRAM
    ld de, FontTiles
    ld hl, $8800
    ld bc, FontTilesEnd - FontTiles
    call LCDMemcpy

    ret


GameStateManager::
    call WaitVBlank
    call DisableSTATInterrupts

    ld a, [wCurrentGameState]
    cp a, 0
    jp z, .titleScreenState

    cp a, 1
    jp z, .gameplayState

    cp a, 2
    jp z, .gameOverState
    
    ret


.titleScreenState:
    call InitTitleScreen
    call UpdateTitleScreen

    jp GameStateManager


.gameplayState:
    call InitGameplay
    call UpdateGameplay

    jp GameStateManager


.gameOverState:
    call InitGameOver
    call UpdateGameOver

    jp GameStateManager


SECTION "GameStateVariables", WRAM0


wCurrentGameState:: db
