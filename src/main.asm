INCLUDE "defines.inc"

SECTION "Intro", ROMX

Intro::
    ; Put your code here!
    call InitGameStateMachine
    call GameStateManager
    jr @
