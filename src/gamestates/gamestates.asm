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

    ld a, RAMG_SRAM_ENABLE
    ld [rRAMG], a

    call ValidateChecksum

    cp a, 0
    jp z, .invalidChecksumEnd

.invalidChecksum
    ld de, rChecksumBytes
    ld hl, sChecksum
    ld bc, sChecksumEnd - sChecksum
    call Memcpy
    xor a
    ld [sHiScore], a
    ld [sHiScore + 1], a
    ld a, 2
    ld [sHiScore + 2], a
    xor a
    ld [sHiScore + 3], a
    ld [sHiScore + 4], a
    ld [sHiScore + 5], a

.invalidChecksumEnd

    ld a, RAMG_SRAM_DISABLE
    ld [rRAMG], a

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
