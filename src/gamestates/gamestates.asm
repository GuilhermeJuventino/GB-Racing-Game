INCLUDE "defines.inc"

SECTION "Game State Machine", ROM0


InitGameStateMachine::
    ld a, 0
    ld [wCurrentGameState], a
    ret


GameStateManager::
    call WaitVBlank

    ; Turning off LCD
    xor a
    ld [rLCDC], a

    ld a, [wCurrentGameState]
    cp a, 0
    jp z, .titleScreenState

    ret


.titleScreenState:
    call InitTitleScreen
    call UpdateTitleScreen

    ret


SECTION "GameStateVariables", WRAM0
wCurrentGameState: db
