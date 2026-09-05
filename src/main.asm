INCLUDE "defines.inc"

SECTION "Intro", ROMX

Intro::
    ; Put your code here!
    ld a, RAMG_SRAM_DISABLE
    ld [rRAMG], a

    ; Loading game's music into memory
    xor a
    ldh [rAUDENA], a ; disable audio
    ld a, $FF
    ldh [rAUDENA], a ; enable audio
    ldh [rAUDTERM], a ; Even pan (mono)
    ld a, $77
    ldh [rAUDVOL], a ; Even volume per channel

    ; Initializing hUGEDriver
    ld hl, race_song
    call hUGE_init

    call InitGameStateMachine
    call GameStateManager
    jr @
