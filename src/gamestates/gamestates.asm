INCLUDE "defines.inc"

SECTION "Game State Machine", ROM0


InitGameStateMachine::
    ld a, 0
    ld [wCurrentGameState], a
    ret


GameStateManager::
    call WaitVBlank

    ld a, [wCurrentGameState]
    cp a, 0
    jp z, .titleScreenState

    cp a, 1
    jp z, .gameplayState
    
    ret


.titleScreenState:
    call InitTitleScreen
    call UpdateTitleScreen

    jp GameStateManager


.gameplayState:
    call InitGameplay
    call UpdateGameplay

    jp GameStateManager


SECTION "GameStateVariables", WRAM0
wCurrentGameState:: db
